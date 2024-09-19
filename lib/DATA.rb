module DATA
	MONSTER = {
		106 => {name: "蒼幽狼", attr: '_w', race: '_b' },
		131 => {name: "水遊俠", attr: '_w', race: '_h' },
		133 => {name: "水舞劍神", attr: '_w', race: '_h' },
		136 => {name: "炎舞軍神", attr: '_f', race: '_h' },
		137 => {name: "木遊俠", attr: '_e', race: '_h' },
		139 => {name: "疾風神射手", attr: '_e', race: '_h' },
		140 => {name: "光遊俠", attr: '_l', race: '_h' },
		142 => {name: "萬劍遊俠", attr: '_l', race: '_h' },
		145 => {name: "暗影劍豪", attr: '_d', race: '_h' },
		439 => {name: "炎鎧戰士", attr: '_f', race: '_b' },
		442 => {name: "暗影鬥士", attr: '_d', race: '_b' },
		443 => {name: "占星蛙法師", attr: '_w', race: '_b'},
		444 => {name: "道法飄蟲", attr: '_f', race: '_b', star: 3, lv: 99, hp: 952, atk: 389, re: 43},
		446 => {name: "賜福蜜蜂", attr: '_l', race: '_b', star: 3, lv: 99, hp: 943, atk: 338, re: 50},
		447 => {name: "奧秘魚術士", attr: '_d', race: '_b'},
		448 => {name: "符靈典範 ‧ 綠茵國王", attr: '_e', race: '_b'},
		1224 => {name: "犬神護佑 ‧ 鈴子", attr: '_f', race: '_b', star: 6, lv: 99, hp: 3328, atk: 1528, re: 285},
		1239 => {name: "變臉火術 ‧ 切西亞", attr: '_f', race: '_g', star: 6, lv: 99, hp: 3209, atk: 1651, re: 314},
	}
	AS = {
		444 => {name: "火焰攻擊", charge: 'CD', num: 5, description: "對敵方全體造成３倍火屬性傷害"},
		1224 => {name: "炙熱爪擊", charge: 'CD', num: 8, description: "將１０個固定位置的符石轉化：當中的火符石轉化為火強化符石，其他符石則轉化為火符石。１回合內，火屬性及獸類攻擊力２倍"},
		1239 => {name: "三原靈陣 ‧ 血燄", charge: 'CD', num: 8, description: "所有符石隨機轉化為水、火、木及心符石，同時火符石出現率上升，並將火符石以火強化符石代替"},
	}
end

module ENEMY
	SKILL = {
		0 => {name: "x", description: "x"},
		1 => {name: "強化盾", description: "敵人只會受到強化符石的攻擊傷害"},
		30 => {name: "人類剋制 ‧ 攻", description: "召喚師隊伍中有人類成員時，敵人攻擊力提升"},
		32 => {name: "神族剋制 ‧ 攻", description: "召喚師隊伍中有神族成員時，敵人攻擊力提升"},
		50 => {name: "無法控制", description: "敵人會無視所有控制技能"},
		75 => {name: "三屬盾", description: "同時消除水符石，火符石及木符石才會對敵人造成攻擊傷害"},
		100 => {name: "水轉自身", description: "每回合敵人會把水符石轉化為敵人屬性的符石"},
		123 => {name: "問號符石5 ‧ 15%", description: "敵人會大幅掉落隱藏符石"},
		134 => {name: "魔族剋制 ‧ 攻", description: "召喚師隊伍中有魔族成員時，敵人攻擊力提升"},
		147 => {name: "20%盾", description: "每回合攻擊最多只能造成敵人生命力２０％的傷害(主動技除外)"},
		150 => {name: "50%盾", description: "每回合攻擊最多只能造成敵人生命力５０％的傷害(主動技除外)"},
		309 => {name: "越戰越強 ‧ 金", description: "敵人生命力愈低時，攻擊力會大幅提升，生命力３０％或以下時會連撃２次"},
	}
end

module FLOOR_DATA
  FLOOR = {
		"遠洋的王者" => {
			name: "符靈之主 地獄級",
			setting: ["x", "x", "random1", "x", "x"],
			waves: [
				[{monsterId: 444, atk: 6877, CD: 1, duration: 1, hp: 18994, dfs: 10, characteristic: 100},{monsterId: 443, atk: 6041, CD: 1, duration: 1, hp: 39708, dfs: 40, characteristic: 150},{monsterId: 446, atk: 6221, CD: 2, duration: 2, hp: 29014, dfs: 30, characteristic: 50},{monsterId: 447, atk: 6356, CD: 2, duration: 2, hp: 61953, dfs: 60, characteristic: 123}],
				[{monsterId: 137, atk: 4727, CD: 2, duration: 2, hp: 233936, dfs: 40, characteristic: 30},{monsterId: 140, atk: 4954, CD: 2, duration: 2, hp: 234159, dfs: 39, characteristic: 32},{monsterId: 131, atk: 4725, CD: 2, duration: 2, hp: 233823, dfs: 40, characteristic: 134}],
				[{monsterId: 133, atk: 6270, CD: 1, duration: 1, hp: 640735, dfs: 606, characteristic: 1},{monsterId: 136, atk: 6690, CD: 1, duration: 1, hp: 629985, dfs: 594, characteristic: 1},{monsterId: 139, atk: 6273, CD: 1, duration: 1, hp: 643423, dfs: 600, characteristic: 1},{monsterId: 142, atk: 6687, CD: 1, duration: 1, hp: 646611, dfs: 579, characteristic: 1},{monsterId: 145, atk: 6690, CD: 1, duration: 1, hp: 640735, dfs: 582, characteristic: 1}],
				[{monsterId: 439, atk: 10644, CD: 2, duration: 2, hp: 473500, dfs: 240, characteristic: 309},{monsterId: 442, atk: 9680, CD: 1, duration: 1, hp: 462800, dfs: 5250, characteristic: 147}],
				[{monsterId: 448, atk: 10520, CD: 1, duration: 1, hp: 2058000, dfs: 9800, characteristic: 75}]
			]
		},
		2 => {
		name: "日蝕之子 地獄級",
		setting: ["random2", "random3", "x", "x", "random3", "x"],
		waves: [
			[{monsterId: 106, atk: 6831, CD: 2, duration: 2, hp: 15, dfs: 20, characteristic: 0},{monsterId: 108, atk: 7624, CD: 2, duration: 2, hp: 12, dfs: 20, characteristic: 0},{monsterId: 110, atk: 7063, CD: 2, duration: 2, hp: 15, dfs: 20, characteristic: 0}],
			[{monsterId: 106, atk: 6831, CD: 2, duration: 2, hp: 15, dfs: 20, characteristic: 0},{monsterId: 108, atk: 7624, CD: 2, duration: 2, hp: 12, dfs: 20, characteristic: 0},{monsterId: 110, atk: 7063, CD: 2, duration: 2, hp: 15, dfs: 20, characteristic: 0}],
			#[{monsterId: 113, atk: 8314, CD: 2, duration: 2, hp: 8, dfs: 39, characteristic: 57},{monsterId: 115, atk: 8579, CD: 2, duration: 2, hp: 9, dfs: 39, characteristic: 57}],
		]},
 }

end