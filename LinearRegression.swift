//
//  LinearRegression.swift
//  DictoCounter
//
//  Created by Raleigh Clemens on 4/11/21.
//

public class LinearRegression{
    
    class func computeError(m: Double, b: Double, points: [[Double]]) -> Double{
        var totalError = 0.0
        
        for i in 0...points.count-1{
            let x = points[i][0]
            let y = points[i][1]
            totalError += Double((y - (m*x + b))*(y - (m*x + b))) //squared error
        }
        
        return totalError/Double(points.count)
    }
    
    class func stepGradient(m_current: Double, b_current: Double, points: [[Double]], learningRate: Double) -> [Double]{
        var b_gradient = 0.0
        var m_gradient = 0.0
        
        let previous_error = computeError(m: m_current, b: b_current, points: points)
        let N = Double(points.count)
        //print(N)
        
        for i in 0...points.count-1{
            let x = points[i][0]
            let y = points[i][1]
            
            //print("Points \(x), \(y)") correct pts
            //divide by N to normalize gradient on each iteration
            
            b_gradient += -(2/N) * (y - ((m_current * x) + b_current))
            m_gradient += -(2/N) * x * (y - ((m_current * x) + b_current))
            
            //print("Update \(b_gradient), \(m_gradient)")
        }
        
        //print("Gradients \(b_gradient), \(m_gradient)")
        
        //when b_grad >0, we are on the rhs of the b cross section. we want to have b_grad closest to 0 as possible,
        //so we subtract from b (namely scaled by b_grad value) to get closer to the rate. vice versa for b_grad < 0
        //and same strategy for m. it's a 3d function with 2d inputs
        
        let new_m = m_current - (learningRate * m_gradient)
        let new_b = b_current - (learningRate * b_gradient)
        
        let new_error = computeError(m: new_m, b: new_b, points: points)
        
        return [new_m, new_b, previous_error, new_error]
    }
    
    class func descent(points: [[Double]], starting_m: Double, starting_b: Double, learningRate: Double, numIterations: Int) -> [Double]{
        
        var modifiable_learning_rate = learningRate
        var b = starting_b
        var m = starting_m
        
        for _ in 0...numIterations{
            let outputs = stepGradient(m_current: m, b_current: b, points: points, learningRate: modifiable_learning_rate)
            m = outputs[0]
            b = outputs[1]
            
            if outputs[3] > outputs[2]{ //if the revised/new error is larger than previous error, reduce learning rate
                //print("oooooo problem")
                modifiable_learning_rate /= 2
            }
            else{
                modifiable_learning_rate *= 1.05
            } //0.00027820154226527674 with
            
        }
        
        print(modifiable_learning_rate, learningRate)
        
        return [m,b]
    }
}

