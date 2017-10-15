//
//  vcJavaApis.swift
//  MostPopJavaApi
//
//  Created by Bruno Garcia on 14/10/2017.
//  Copyright © 2017 Santos Brasil. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class vcJavaApis: baseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var pagina : Int = 1
    let segueDetalhe = "segueDetalhe"

    @IBOutlet weak var tbDados: UITableView!
    var DadosAPI = ApiList();
    var Dados = [JSON]()
    var DadosRepo = [JSON]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buscaDadosRepositorios()
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Dados.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            //let section = indexPath.section
        let i = indexPath.row
        
        let cell = self.tbDados.dequeueReusableCell(withIdentifier: "cellItem", for: indexPath) as! cellRepositorio
    
        cell.txtNomeRepositorio.text = Dados[i]["name"].string
        cell.txtNome.text = Dados[i]["owner"]["login"].string
        cell.txtDescricaoRepositorio.text = Dados[i]["description"].string
        cell.txtFork.text = "\(Dados[i]["forks"].int!)"
        cell.txtStar.text = "\(Dados[i]["stargazers_count"].int!)"
        cell.imgResponsavel.downloadedFrom(link: Dados[i]["owner"]["avatar_url"].string!)
        
        cell.viewBackground.setBordaArredondada()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        DadosRepo = [JSON]()
        buscaDetalheRepositorio(owner: Dados[indexPath.row]["owner"]["login"].string!, repo: Dados[indexPath.row]["name"].string!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == segueDetalhe
        {
            let destination = segue.destination as? vcRepoDetalhe
            let tableIndex = ((sender as! IndexPath) as NSIndexPath).row;
            destination!.RepoDetalhe = DadosRepo
        }
    }
    
    
    func buscaDadosRepositorios(){
        do {
            carregando(msg: "Aguarde...")
            let url = "https://api.github.com/search/repositories?q=language:Java&sort=stars&page=\(pagina)"
            
            Alamofire.request(url).responseJSON { response in
                if response.result.value != nil {
                    if response.result.value != nil {
                        if let jsonRetorno:JSON = JSON(response.result.value!) {
                            if let itens = jsonRetorno["items"].array {
                                self.Dados = itens
                            }
                        }
                    }
                }
                self.tbDados.reloadData()
                self.fecharCarregando()
            }
        }catch {
            self.fecharCarregando()
            print("ERRO")
        }
    }
    
    func buscaDetalheRepositorio(owner: String, repo: String){
        do {
            carregando(msg: "Aguarde...")
            let url = "https://api.github.com/repos/\(owner)/\(repo)/pulls"
            
            Alamofire.request(url).responseJSON { response in
                if response.result.value != nil {
                    if response.result.value != nil {
                        if let jsonRetorno:JSON = JSON(response.result.value!) {
                            if let itens = jsonRetorno.array {
                                self.DadosRepo = itens
                            }
                        }
                        self.performSegue(withIdentifier: self.segueDetalhe, sender: nil);
                    }
                }
                self.fecharCarregando()
            }
        }catch {
            self.fecharCarregando()
            print("ERRO")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
