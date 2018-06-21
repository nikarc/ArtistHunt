//
//  EncodeURIComponent.swift
//  MusicApp
//
//  Created by Nick Arcuri on 6/19/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import Foundation

extension String {
    func encodeURIComponent() -> String? {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-_.!~*'()")
        
        return self.addingPercentEncoding(withAllowedCharacters: characterSet)
    }
}
