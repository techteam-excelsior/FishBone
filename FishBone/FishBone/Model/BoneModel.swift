//
//  BoneModel.swift
//  FishBone
//
//  Created by Gaurav Pai on 08/05/19.
//  Copyright © 2019 excelsiortechteam. All rights reserved.
//

import Foundation

struct boneData: Codable {
    var boneText: String
    var subBoneCount: Int
    var isWhyEnabled: Bool
    var whyText: String
    var subBoneArray : [boneData]
    
    init() {
        boneText = ""
        subBoneCount = 0
        isWhyEnabled = false
        whyText = ""
        subBoneArray = []
    }
}

class entireBoneData: Codable {
    var bones = [boneData]()
    var primaryBoneCount = 0
}
