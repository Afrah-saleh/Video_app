//
//  TipKit.swift
//  1
//
//  Created by Faizah Almalki on 28/07/1446 AH.
//

import Foundation
import TipKit

struct AddItemTip: Tip {
    var title: Text {
        Text(" إقتصاص ")

    }
    
    var message: Text? {
        Text("قص افضل اللقطات واحفظها")
        
            .font(.system(size: 16))
        
            
    }
    
    

        
     
    }
struct PhotoTip: Tip {
    var title: Text {
        Text("إقتباس")
        

    }
    
    var message: Text? {
        Text("إقتبس الي يعجبك بسهوله")
        
        
    }
  
    
}

