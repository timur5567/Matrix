//
//  Matrix.swift
//  Matrix multiplication
//
//  Created by msoft on 13.01.2021.
//

import Foundation
import Accelerate

 class Matrix: CustomStringConvertible {
    
    internal var data:Array<Double>
    
    var rows: Int
    var columns: Int
    
    var size: Int {
        get {
            return rows * columns
        }
    }
    
    var description: String {
        
        var d = ""
        for row in 0..<rows {
            
            for col in 0..<columns {
                
                let s = String(self[row,col])
                d += s + " "
            }
            
            d += "\n"
        }
        return d
    }
    
    init(_ data:Array<Double>, rows:Int, columns:Int) {
        self.data = data
        self.rows = rows
        self.columns = columns
    }
    
    init(rows:Int, columns:Int) {
        self.data = [Double](repeating: 0.0, count: rows*columns)
        self.rows = rows
        self.columns = columns
    }
    
    func copy(with zone: NSZone? = nil) -> Matrix {
        let m = Matrix(self.data, rows:self.rows, columns:self.columns)
        return m
    }
    
    
    subscript(row: Int, col: Int) -> Double {
        get {
            precondition(row >= 0 && col >= 0 && row < self.rows && col < self.columns, "Index out of bounds")
            return data[(row * columns) + col]
        }
        
        set {
            precondition(row >= 0 && col >= 0 && row < self.rows && col < self.columns, "Index out of bounds")
            self.data[(row * columns) + col] = newValue
        }
    }
    
    
    func row(index:Int) -> [Double] {
        
        var r = [Double]()
        for col in 0..<columns {
            r.append(self[index,col])
        }
        return r
    }
    
    
    func col(index:Int) -> [Double] {
        var c = [Double]()
        for row in 0..<rows {
            c.append(self[row,index])
        }
        return c
    }
    
    func clear() {
        self.data = [Double](repeating: 0.0, count: self.rows * self.columns)
        self.rows = 0
        self.columns = 0
    }
    
    
}

// MARK: Matrix Operations
func +(left: Matrix, right: Matrix) -> Matrix {
    
    precondition(left.rows == right.rows && left.columns == right.columns)
    
    let m = Matrix(left.data, rows: left.rows, columns: left.columns)
    
    for row in 0..<left.rows {
        
        for col in 0..<left.columns {
            
            m[row,col] += right[row,col]
            
        }
    }
    return m
}

func -(left: Matrix, right: Matrix) -> Matrix {
    
    precondition(left.rows == right.rows && left.columns == right.columns)
    
    let m = Matrix(left.data, rows: left.rows, columns: left.columns)
    
    for row in 0..<left.rows {
        
        for col in 0..<left.columns {
            
            m[row,col] -= right[row,col]
            
        }
    }
    return m
}

func *(left:Matrix, right:Double) -> Matrix {
    return Matrix(left.data * right, rows: left.rows, columns: left.columns)
}

func *(left:Double, right:Matrix) -> Matrix {
    return right * left
}

func *(left:Matrix, right:Matrix) -> Matrix {
    
    var mutex = pthread_mutex_t()
    pthread_mutex_init(&mutex, nil)
    
    var lcp = left.copy()
    var rcp = right.copy()
    
    if (lcp.rows == 1 && rcp.rows == 1) && (lcp.columns == rcp.columns) { // exception for single row matrices (inspired by numpy)
        rcp = rcp^
    }
    else if (lcp.columns == 1 && rcp.columns == 1) && (lcp.rows == rcp.rows) { // exception for single row matrices (inspired by numpy)
        lcp = lcp^
    }
    
    guard lcp.columns == rcp.rows else { fatalError("These matrices cannot be multipied") }
    
    let dot = Matrix(rows:lcp.rows, columns:rcp.columns)
    
    for rindex in 0..<lcp.rows {
        for cindex in 0..<rcp.columns {
            
            DispatchQueue.global().async {
                pthread_mutex_lock(&mutex)
                
                let a = lcp.row(index: rindex) ** rcp.col(index: cindex)
                dot[rindex,cindex] = a
                
                do {
                    pthread_mutex_unlock(&mutex)
                }
            }
        }
    }
    
    return dot
}

func ==(left:Matrix, right:Matrix) -> Bool {
    return left.data == right.data
}


// Transpose
postfix operator ^

postfix func ^(m:Matrix) -> Matrix {
    let transposed = Matrix(rows:m.columns, columns:m.rows)
    for row in 0..<m.rows {
        for col in 0..<m.columns {
            transposed[col,row] = m[row,col]
        }
    }
    return transposed
}

typealias Vector = [Double]

func *(left:Vector, right:Vector) -> Vector {
    var d = [Double]()
    for i in 0..<left.count {
        d.append(left[i] * right[i])
    }
    return d
}

func *(left:Vector, right:Double) -> Vector {
    var d = [Double]()
    for i in 0..<left.count {
        d.append(left[i] * right)
    }
    return d
}

func *(left:Double, right:Vector) -> Vector {
    return right * left
}

infix operator **

func **(left:Vector, right:Vector) -> Double {
    
    precondition(left.count == right.count)
    
    var d : Double = 0
    for i in 0..<left.count {
        d += left[i] * right[i]
    }
    return d
}
