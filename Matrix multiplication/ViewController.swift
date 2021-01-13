//
//  ViewController.swift
//  Matrix multiplication
//
//  Created by msoft on 10.01.2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let matrix1 = Matrix(rows: 100, columns: 100)
        let matrix2 = Matrix(rows: 100, columns: 100)
        
        let sumMatr = matrix1 * matrix2
        
        print(sumMatr)
    }
}


