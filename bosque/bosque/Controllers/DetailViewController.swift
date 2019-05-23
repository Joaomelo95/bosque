//
//  DetailViewController.swift
//  bosque
//
//  Created by João Melo on 03/05/19.
//  Copyright © 2019 João Melo. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    // Variável da WKWebView
    @IBOutlet weak var WKWebView: WKWebView!
    
    // Variáveis dos sites que vamos acessar
    let URLONG1 = "https://www.wwf.org.br"
    let URLONG2 = "https://www.unicef.org/brazil/"
    
    
    private var activityIndicatorContainer: UIView!
    private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Qual site será acessado
        if areaSelectedGlobal == 1 {
            sendRequest(urlString: URLONG1)
        } else if areaSelectedGlobal == 2 {
            sendRequest(urlString: URLONG2)
        }
        
        setToolBar()
        

        
        WKWebView.navigationDelegate = self
    }
    
    // Converter a String em URL e carregar a URL
    private func sendRequest(urlString: String) {
        let myURL = URL(string: urlString)
        let myRequest = URLRequest(url: myURL!)
        WKWebView.load(myRequest)
    }
    
    // Funçao do indicador de atividade
    fileprivate func setActivityIndicator() {
        // Configurar o containerView de background para o indicador
        activityIndicatorContainer = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        activityIndicatorContainer.center.x = WKWebView.center.x
        activityIndicatorContainer.center.y = WKWebView.center.y - 44
        activityIndicatorContainer.backgroundColor = UIColor.black
        activityIndicatorContainer.alpha = 0.8
        activityIndicatorContainer.layer.cornerRadius = 10
        
        // Configurar o indicador de atividade
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorContainer.addSubview(activityIndicator)
        WKWebView.addSubview(activityIndicatorContainer)
        
        // Constraints
        activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorContainer.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorContainer.centerYAnchor).isActive = true
    }
    
    // Ajusta a toolBar
    fileprivate func setToolBar() {
        let screenWidth = self.view.bounds.width
        let backButton = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(goBack))
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        toolBar.isTranslucent = false
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.items = [backButton]
        WKWebView.addSubview(toolBar)
        // Constraints
        toolBar.bottomAnchor.constraint(equalTo: WKWebView.bottomAnchor, constant: 0).isActive = true
        toolBar.leadingAnchor.constraint(equalTo: WKWebView.leadingAnchor, constant: 0).isActive = true
        toolBar.trailingAnchor.constraint(equalTo: WKWebView.trailingAnchor, constant: 0).isActive = true
    }
    
    // Função para voltar à tela inicial
    @objc private func goBack() {
        if WKWebView.canGoBack {
            WKWebView.goBack()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // Função para controlar a animação do indicador de atividade
    fileprivate func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            activityIndicatorContainer.removeFromSuperview()
        }
    }
}

extension DetailViewController: WKNavigationDelegate {
    func webView(_ WKWebView: WKWebView, didFinish navigation: WKNavigation!) {
        self.showActivityIndicator(show: false)
    }
    func webView(_ WKWebView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Ajusta o indicador toda vez que a webView começar a carregar
        self.setActivityIndicator()
        self.showActivityIndicator(show: true)
    }
    func webView(_ WKWebView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.showActivityIndicator(show: false)
    }
    
}
