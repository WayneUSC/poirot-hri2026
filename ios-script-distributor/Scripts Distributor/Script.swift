import Foundation

struct Script: Codable {
    let name: String
    let roles: [String]
    let acts: [Act]
    let totalClueStages: Int
    let clueStages: [ClueStage]
    let roleScripts: [String: [Int: String]] // [角色名称: [幕编号: 剧本URL]]
    let publicClueImageURLsDict: [Int: [String]] // [线索阶段编号: [图片URL]]
    let privateClueImageURLsDict: [String: [Int: [String]]] // [角色名称: [线索阶段编号: [图片URL]]]
}

struct Act: Codable {
    let number: Int
    let name: String
}

struct ClueStage: Codable {
    let number: Int
    let name: String
}

struct PlayerRole: Codable {
    let name: String
    
    var displayName: String {
        return name
    }
}
