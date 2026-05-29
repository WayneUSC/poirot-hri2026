//
//  ScriptsLibraryController.swift
//  Scripts Distributor
//
//  Created by Wen Chen on 8/28/24.
//

import UIKit

private let reuseCellIdentifier = "Cell"
private let reuseSectionHeaderIdentifier = "SectionHeader"
//let sriptsNames = [
//        "关于北原千夜的一切",
//        "北宋奇案·汴京",
//        "大漠谣",
//        "头颅们的失眠夜",
//        "永不褪色的山楂林",
//        "年轮",
//        "归途七万里",
//        "月落洼",
//        "水镜八奇",
//        "猫岛谋杀循环",
//        "病娇男孩的精分日记",
//        "窗边的女人",
//        "苍歧",
//        "蛊魂铃"
//    ]
//let scriptsKinds = [
//        "日式 还原 演绎法 进阶",
//        "古风 推理 悬疑 高阶",
//        "古风 情感 沉浸 进阶",
//        "日式 推理 惊悚 高阶",
//        "民国 情感 沉浸 进阶",
//        "中式 推理 设定 高阶",
//        "民国 情感 沉浸 新手",
//        "民国 推理 悬疑 高阶",
//        "架空 阵营 博弈 进阶",
//        "架空 推理 悬疑 其他",
//        "中式 推理 惊悚 进阶",
//        "架空 推理 惊悚 新手",
//        "古风 情感 演绎 进阶",
//        "架空 推理 惊悚 新手"
//    ]
//let scriptsScores = [
//        "出类拔萃 8.6分",
//        "出类拔萃 8.7分",
//        "值得一玩 7.8分",
//        "出类拔萃 8.8分",
//        "出类拔萃 8.5分",
//        "神作必玩 9.0分",
//        "出类拔萃 8.8分",
//        "好评如潮 8.4分",
//        "出类拔萃 8.7分",
//        "神作必玩 9.1分",
//        "神作必玩 9.0分",
//        "出类拔萃 8.6分",
//        "好评如潮 8.5分",
//        "好评如潮 8.5分"
//    ]
//let scriptIntros = [
//    "北宋奇案·汴京": "一段北宋时期耻辱的历史，两个南宋同朝为官的叔侄，三位曾经纠葛种种的帝王，竟与那四起未曾结案的密室斩首案，深深牵扯。而那尘封于汴京城下的秘密，亦随着它的陨落，或被深埋，或欲出土……\n\n\n\n\n\n\n\n\n", "头颅们的失眠夜": "在京都一处偏僻的郊外，有一间奇怪的二层酒馆，曾有人在阴雨天目睹过这间酒馆，但当天空放晴时，酒馆却像没存在过一般离奇地消失了。这间只会在雨天出现的神秘酒馆，由于每次出现时都会围绕着朦胧的水雾，因此人们将其称之为雾雨酒馆......昭和末年，推理小说家昨日非门因病去世，其生前完成的最后一部作品在死后被编纂成书出版。自那之后，这位曾经栖身于雾雨酒馆的名侦探逐渐被人们遗忘，仿佛同酒馆一起消失在了昭和年代的尽头......平成十年的一个雨夜，神秘的男人只身前往已经废弃的雾雨酒馆，而酒馆二楼的窗边，六颗头颅早已在圆桌上静候着他的到来......“各位，我的名字叫做四枫院真愿，希望在座的各位可以协助我一起破解昨日先生最后的谜题。”沉睡的头颅被唤醒，书籍的扉页被翻开，五起尘封的密室斩首事件逐渐浮现：囚笼中的少女，你为何会被斩首于空无一人的建筑之中？谣喙里的恶魔，你为何提着自己的人头在门前吟唱歌谣？可怜的女人，你的人头又为何漂浮在水池之上？绝望的男人，你又为何抱着自己的人头抵在冰冷的铁门之后？还有那诡异的传说，为何一次又一次地被印证？倘若这些案件中不存在常人无法想象的恶魔般的诡计或是常人无法理解的恐怖动机，那这些案件便只能解释为怪谈或其他超自然现象。——昨日非门",
//        "水镜八奇": "汉朝末年，董卓挟天子以令诸侯，战神吕布为其征讨，四方群雄并起。水镜门下八奇，谋冠天下。明修栈道，暗度陈仓火烧赤壁，空城弹唱甄姬远行，奉孝遗殇铜雀春深，不诉悲凉。就在此时，一个商人悄然走进这个时代，牵出群英纷争，乱世无常。群雄逐鹿，大风骤起水镜八奇出山了\n\n\n\n\n\n\n\n\n",
//        "关于北原千夜的一切": "受北原千夜先生所托，由我来向各位转述，关于北原千夜的一切。\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
//        "病娇男孩的精分日记":"我叫萧何。我一生的时间，是别人的七分之一，生命的厚度却是别人的七倍，因为这具身体里住着七个“我”，但别误会，我们可不像电影里那些暴戾和不可理喻的分裂人格，为了能更好的同处，我们分别取名星期一至星期日。事实上，我们也是按照一周7天轮流出现，拥有自己独立的生活。我们之间从未打过照面，便签条上的文字是我们沟通的唯一途径，除此之外，每个人都有一本日记，记录着自己的小秘密，我们彼此约定，绝对不能偷看其他人的日记。总之，我有七个我，我便拥有了更丰盈的生命和更孤单的生活。热闹是我的，孤独也是我的。 ",
//        "猫岛谋杀循环":"孤僻少年桃山优离奇自杀，为了追寻真相，心理教授将记载当年事件的六本日记启封，邀请了六位看似无关的客人来参加这场推理的饕餮晚宴。血缸中溺亡的人彘；铁架上残破的肢体；暴雨时离奇的断首；悬崖下模糊的头皮；熔炉里碳化的骨架；密室内蒸发的人影。无人生还的诅咒，是开启谋杀循环的源头。丧心病狂的凶手，享受着变态颤粟的动机。也许，只有足够了解变态的人，才能看破隐藏在猫岛的绝望真相。又或许，只有真正的变态才能理解变态的真谛。那么，各位远道而来参与推理的客人们，你们又到底是哪种人呢？\n\n\n\n\n\n\n\n\n",
//        "永不褪色的山楂林": "漫长的北行中，燕京大学赴苏俄学习的青年们挤在一起，听先生讲最后一课。东北寒冷干燥的夜色里，先生沉吟着点一支烛火，讲文学与改革，讲松花江与伏尔加河，讲俄文与普希金的诗，最后讲十月革命与列宁，讲他们不知能否到达的莫斯科。燕园的晚风吹过碎金般的山楂果，下坠时，往昔漫长的年月——簇拥回你身边，它们都和这片山楂林一样，永不褪色，永远年轻。\n\n\n\n\n\n\n\n\n",
//        "大漠谣": "玉门关外，月下黄沙皑皑，绿洲清泉盈盈。西域，本三十六国，其后稍分至五十，皆在匈奴之西，乌孙之南，东则接汉。沙海驼铃，枯树夕阳，这里本是一片与世隔绝的荒漠，当财富与文化慕名而来，野心与欲望亦随之而至孔雀河逶迤向西，三十六国铸造西域的传奇。汉匈两个帝国的交战中，无人听见大漠子民的悲鸣。当楼兰古国化身为西域的缩影，时间尽头，黄沙掩埋的千口棺木或将重现人间屏息静听，阵阵梵音与祷告中是谁不屈的高歌戈壁铁马间大汉，匈奴与西域共同谱写的正是一曲-大漠谣\n\n\n\n\n\n\n\n\n",
//        "苍歧": "雪初生，寒山满，四方孤雁，别阳关......这阳关，便是苍阳。地处苍歧十二州腹地，汇聚天下帝王之气。苍阳城里曾有天下闻名的太学，聚天下之材，定天下之势。尔后却被某位帝王所废弃。千年书院，因何而废？史曰：王侯之欲，年少之情，幻如鬼魅，不可妄谈。只是，总有人会发现。这已经荒废了许久的书院中，有一颗叶红如血的古树，在方圆十里草木皆枯的情景下，—直生机盎然着。偶尔，有叶因秋风萧瑟，如红蝶坠地，缓缓飘进不远处亦不干涸的愿池之中。有人说，曾看到涟漪里晕着—些画影。那影中，缨锋似笔，青史如刀。刻着六位少年，浮沉于天下的，昨日悲欢。",
//        "归途七万里": "日夕路远，暮钟声风雨飘摇。此时，故土走向末路。六名幼童被选中，少不更事的他们别去了父母之邦，踏七万里长途。船舶上的白烟袅袅飘着，轮船浪打着浪，他们就这样挤在船舱内，意欲揭开华夏之外的神秘面纱。那是不见故土的哈特福德，等夜风开始唱，于是教堂的钟摆始终摇晃，金黄的树叶盘旋着，雨滴起起落落。这里，风也自由、雨也洒脱。自乘上大船那一刻起，他们的命运，将与这个国家一起，卷入这历史的滚滚波涛之中。半生流离，百丈红尘，又见朱甍碧瓦，画栋雕梁。六名少年紧紧交握着彼此的手，依附共生，站在历史的转折点，等待他们的是荣耀还是桎梏？\n\n\n\n\n\n\n\n\n",
//        "年轮": "位于T市郊外160多公里一座山谷内的废墟，原先是一个仅有数十户人口的小村。一天夜里突发大火,由于谷内山路崎岖且没有外接水源导致救火工作极其困难。好在深凹的地形致使火势并没有向外蔓延，天蒙蒙亮时火势才渐渐熄灭。那次大火对山谷内的石壁树木造成了破坏，后来每每有风吹过时总能听到呜呜的哭声，仿佛是当年那些冤魂在为自己哭诉。外面通往山谷的地势险峻再加上村子位置较为隐蔽使得这些年政府并没有对这片废墟进行修缮。今天，一群人聚集到了这里...\n\n\n\n\n\n\n\n\n",
//        "月落洼": "故事发生在1914年”，这回的舞台在美丽的西塘古镇。数十年前，一块天降陨石落在古镇西南的一处茂林里，冲击成洼，附近的水流注入后形成湖面。传说此乃月中蟾宫的司时之石，误落凡间，因此得名“月落洼”。之前有一位姓安的学者在月落洼附近修建“时珞庄”，带家眷来此定居。此后他常往返上海，眼下正担任着“圣约翰大学”神学院“灵魂存在”课程的临时老师……\n\n\n\n\n\n\n\n\n",
//        "窗边的女人": "夜深，电脑响起了提示音，我已习惯性正要关闭，却发现是我一直关注的某个论坛的新消息，本能的好奇让我打开这个很久没更新的论坛。却发现天气氛异常活跃，我看了看日历，噢，原来十年了，那起未结的分尸案到今天已经十年了。越过水墨江南的青砖瓦墙，她在地下还好吗?这么多年，原来世上的人还没忘记她……\n\n\n\n\n\n\n\n\n",
//        "蛊魂铃": "靖康二年，金兵南犯，开封不保，北宋灭亡。九卿太常叶氏，九卿太保孙家，世代将军龙府，经商大户韩府等一众被迫流亡，最终迁居西北兴元府辖内万沙镇。南宋乾道年间，万沙镇不断有人枉死，为一查究竟，大散关将军秦枫调任万沙镇县令。调任首日，便邀请诸位士族前来赴宴。至此，一幕幕往事就此揭开，一个个阴谋接踵而来……\n\n\n\n\n\n\n\n\n"
//]
//let scriptMembers = [
//    "北宋奇案·汴京": ["吴瑜", "李师师", "杨沂中", "樊玉楼", "汪伯彦", "黄潜善"],
//    "头颅们的失眠夜": ["头颅1", "头颅2", "头颅3", "头颅4", "头颅5", "头颅6"],
//    "水镜八奇": ["袁绍", "吕布", "贾诩", "荀彧", "张飞", "孙坚", "甄姬", "孙尚香"],
//    "关于北原千夜的一切": ["向井弘树", "桐生浩一", "京野阳太", "神崎悠人", "鹤见明日香", "唐泽绘梨衣"],
//    "病娇男孩的精分日记": ["日记1", "日记2", "日记3", "日记4", "日记5", "日记6", "日记7"],
//    "猫岛谋杀循环": ["如月岚", "如月唯", "日向彼方", "日向结音", "星川润太郎", "星川真里亚"],
//    "永不褪色的山楂林": ["金菱", "苏越", "瞿蓉", "周缘", "陈白羊", "陈小虎"],
//    "大漠谣": ["伊稚月", "刘知婉", "云起", "安尘", "阿珂娜", "澜安长公主", "班毅"],
//    "苍歧": ["轩辕灵澈", "轩辕明穗", "柳浅", "萧原", "君天离", "林思柔"],
//    "归途七万里": ["容葵", "张眷信", "易澄", "沈月之", "金雅梅", "黄佐廷"],
//    "年轮": ["袁本", "陈烁", "姚波", "王小冉", "刘伯钊"],
//    "月落洼": ["安梧", "尔芙", "吾特", "伍艾菲", "睿司"],
//    "窗边的女人": ["梦秋雪", "普罗米修斯", "囚鸽", "斯文男人", "无常", "黑弥撒"],
//    "蛊魂铃": ["叶昧娘", "韩啸天", "龙晓武", "龙承志", "花月楼", "龙锦坤"]
//]
//let scriptOthers = [
//    "北宋奇案·汴京": "4男2女 8.0小时 高阶",
//    "头颅们的失眠夜": "3男3女 6.0小时 高阶",
//    "水镜八奇": "6男2女 9.0小时 进阶",
//    "关于北原千夜的一切": "4男2女 6.0小时 进阶",
//    "病娇男孩的精分日记": "7男0女 5.0小时 进阶",
//    "猫岛谋杀循环": "3男3女 8.0小时 高阶",
//    "永不褪色的山楂林": "4男3女 7.0小时 进阶",
//    "大漠谣": "3男4女 5.5小时 进阶",
//    "苍歧": "3男3女 5.0小时 进阶",
//    "归途七万里": "3男3女 7.5小时 新手",
//    "年轮": "3男2女 6.0小时 高阶",
//    "月落洼": "3男2女 6.0小时 高阶",
//    "窗边的女人": "4男2女 4.0小时 新手",
//    "蛊魂铃": "4男2女 5.0小时 新手"
//]

let sriptsNames = [
//    "Shadows of Ashwick Manor",
//    "Crimson Secrets on a Stormy Night",
    "审判四重奏-A",
    "Quartet of Judgment-A",
    "审判四重奏-B",
    "Quartet of Judgment-B",
//    "All About Kichiya Kitahara",
//    "The Northern Song Mystery",
//    "The Tale of the Desert",
//    "The Sleepless Night of the Heads",
//    "The Hawthorn Grove That Never Fades",
//    "Rings of Time",
//    "70,000 Miles Homeward",
//    "Moonlit Hollow",
//    "The Eight Wonders of Water Mirror",
//    "Cat Island Murder Cycle",
//    "Diary of a Split-Personality Boy",
//    "The Woman by the Window",
//    "Cangqi",
//    "The Soul Bell of Gu"
];
let scriptsKinds = [
//    "American Restoration Deduction Advanced",
//    "American Restoration Intrigue Intermediate",
    "中式 还原 演绎法 中等",
    "Chinese Restoration Deduction Intermediate",
    "中式 还原 演绎法 中等",
    "Chinese Restoration Deduction Intermediate",
//    "Japanese Restoration Deduction Advanced",
//    "Historical Intrigue Suspense Expert",
//    "Historical Emotional Immersion Intermediate",
//    "Japanese Intrigue Horror Expert",
//    "Republic-Era Emotional Immersion Intermediate",
//    "Chinese Intrigue World-Building Expert",
//    "Republic-Era Emotional Immersion Beginner",
//    "Republic-Era Intrigue Suspense Expert",
//    "Fantasy Faction Strategy Intermediate",
//    "Fantasy Intrigue Suspense Other",
//    "Chinese Intrigue Horror Intermediate",
//    "Fantasy Intrigue Horror Beginner",
//    "Historical Emotional Role-Play Intermediate",
//    "Fantasy Intrigue Horror Beginner"
];
let scriptsScores = [
//    "Outstanding 8.5",
//    "Highly Praised 8.4",
    "强烈推荐 8.4",
    "Highly Praised 8.4",
    "强烈推荐 8.4",
    "Highly Praised 8.4",
//    "Outstanding 8.6",
//    "Outstanding 8.7",
//    "Worth Playing 7.8",
//    "Outstanding 8.8",
//    "Outstanding 8.5",
//    "Must-Play Masterpiece 9.0",
//    "Outstanding 8.8",
//    "Highly Praised 8.4",
//    "Outstanding 8.7",
//    "Must-Play Masterpiece 9.1",
//    "Must-Play Masterpiece 9.0",
//    "Outstanding 8.6",
//    "Highly Praised 8.5",
//    "Highly Praised 8.5"
];
let scriptIntros = [
//    "Shadows of Ashwick Manor": "A century ago, during a grand masquerade ball, Evelyn Crowley was found dead in Ashwick Manor, sparking a string of disappearances. Now, you and a group of strangers are invited to the cursed estate to uncover its dark secrets. As the night deepens, trust fades, and the line between ally and enemy blurs. Will you solve the mystery, or become the manor’s next victim?",
//    "Crimson Secrets on a Stormy Night": "On a stormy night, a gruesome murder shakes a luxurious mansion to its core. The victim is the painter’s eldest daughter, a mysterious figure who had been secretly imprisoned for years due to a terrible crime she committed. When discovered, her headless body lies alone in a locked room. Six individuals within the mansion are drawn into the vortex of suspicion—the female writer, the painter himself, his eldest son, second daughter, youngest son, and the ever-silent butler. As the truth unravels, hidden secrets from their hearts emerge. Who has blood on their hands, and who is pulling the strings behind the scenes? The mystery of this locked-room murder awaits your discovery...",
    "审判四重奏-A": "鲁滨市正值寒冬，秀砀山教堂，一场平静的募捐集会，却成为命案发生的前夜。嫌疑人被捕、尸体被挖出、证人相继出现——随着庭审的临近，六位当事人接连登场，他们彼此之间看似毫无瓜葛，却都藏着过往难以言说的牵连。在法庭之上，他们将交锋于理性与情感之间，真相却似乎总是游走在证词的缝隙之外。是偶然的重逢，还是精心的布局？是为正义发声，还是掩盖罪恶？这一场审判，远不止于法律……\n\n\n\n\n\n\n\n",
    "Quartet of Judgment-A": "In the heart of a bitter winter in Rubing City, a quiet fundraising gathering at Xiudang Mountain Church becomes the eve of a shocking murder. A suspect is arrested, a body unearthed, witnesses step forward—six individuals take the stage as the trial approaches. Though they appear to be strangers, each harbors a past tangled with silent, unseen threads. In the courtroom, reason and emotion collide. Yet the truth seems to slip through the cracks between testimonies. Is this a chance reunion—or a carefully orchestrated design? Do they seek justice—or hide something darker? This trial goes far beyond the law…\n\n\n\n\n\n\n\n",
    "审判四重奏-B": "鲁滨市正值寒冬，秀砀山教堂，一场平静的募捐集会，却成为命案发生的前夜。嫌疑人被捕、尸体被挖出、证人相继出现——随着庭审的临近，六位当事人接连登场，他们彼此之间看似毫无瓜葛，却都藏着过往难以言说的牵连。在法庭之上，他们将交锋于理性与情感之间，真相却似乎总是游走在证词的缝隙之外。是偶然的重逢，还是精心的布局？是为正义发声，还是掩盖罪恶？这一场审判，远不止于法律……\n\n\n\n\n\n\n\n",
    "Quartet of Judgment-B": "In the heart of a bitter winter in Rubing City, a quiet fundraising gathering at Xiudang Mountain Church becomes the eve of a shocking murder. A suspect is arrested, a body unearthed, witnesses step forward—six individuals take the stage as the trial approaches. Though they appear to be strangers, each harbors a past tangled with silent, unseen threads. In the courtroom, reason and emotion collide. Yet the truth seems to slip through the cracks between testimonies. Is this a chance reunion—or a carefully orchestrated design? Do they seek justice—or hide something darker? This trial goes far beyond the law…\n\n\n\n\n\n\n\n",
//    "The Northern Song Mystery: Bianjing": "A shameful chapter of Northern Song history, two uncles and nephews serving the Southern Song court, three entangled emperors, all deeply connected to four unsolved cases of decapitation in locked rooms. Secrets buried under Bianjing’s ruins may remain hidden forever or surface anew...",
//    "The Sleepless Night of the Heads": "On a rainy night in Kyoto, a mysterious two-story tavern appears in the mist but vanishes when the skies clear. In the Heisei era, a man visits this Rainy Tavern, where six heads await his arrival at the round table upstairs. Five sealed cases of decapitation unfold, each shrouded in eerie mystery...",
//    "The Eight Wonders of Water Mirror": "In the twilight of the Han dynasty, as chaos erupts, the Water Mirror’s Eight Wonders emerge, their strategies shaping the turbulent world. A merchant steps into this era, entangling the fates of heroes and villains alike in a storm of intrigue...",
//    "All About Kichiya Kitahara": "Entrusted by Mr. Kitahara, I shall recount his tale for you...",
//    "Diary of a Split-Personality Boy": "My name is Xiao He. Seven personalities reside within me, each living a separate life. Communication between us is limited to post-it notes, and each keeps their own diary. Though lively on the outside, my existence is lonely...",
//    "Cat Island Murder Cycle": "A secluded boy’s mysterious suicide leads to six diaries, inviting six guests to a twisted banquet of deduction. The guests must uncover the chilling truths hidden on Cat Island...",
//    "The Hawthorn Grove That Never Fades": "On their journey to the Soviet Union, students from Yenching University reflect on literature, reform, and revolution, while the timeless beauty of the hawthorn grove witnesses their youth and dreams...",
//    "The Tale of the Desert": "Amidst the clash of empires, the desolation of the Gobi Desert tells a tale of unyielding resilience, as ancient kingdoms rise and fall beneath the eternal sands...",
//    "Cangqi": "A thousand-year-old academy hides secrets of youthful ambition and imperial greed. A mysterious red tree thrives in desolation, its falling leaves revealing forgotten stories...",
//    "70,000 Miles Homeward": "Six children embark on a journey across oceans, their destinies intertwined with a nation’s transformation through triumphs and tribulations...",
//    "Rings of Time": "The remains of a burned-out village whisper tales of tragedy and vengeance, as a group of visitors gathers to uncover its secrets...",
//    "Moonlit Hollow": "Set in 1914 at a serene ancient town, a mysterious meteor-formed lake holds the key to a scholar’s enigmatic legacy...",
//    "The Woman by the Window": "A mysterious forum post revisits an unsolved dismemberment case from a decade ago, stirring memories of an unspeakable crime...",
//    "The Soul Bell of Gu": "In the wake of the Jin invasion, noble families flee to a small town where conspiracies unfold. A new magistrate seeks to unravel the dark truths hidden within the tragedies..."
];
let scriptMembers = [
//    "Shadows of Ashwick Manor": ["Alexander Sterling", "Eleanor Harper", "Victor Caldwell", "Clara Whitmore", "Nathaniel Grayson", "Julian Blackwell"],
//    "Crimson Secrets on a Stormy Night": ["Guest", "Eldest Son", "Youngest Daughter", "Youngest Son", "Painter", "Butler"],
    "审判四重奏-A": ["叶才阳", "唐雅莉", "方崎", "楚幂鹤", "殷弘", "陈浩桐"],
    "Quartet of Judgment-A": ["Ye Caiyang", "Tang Yali", "Fang Qi", "Chu Mihe", "Yin Hong", "Chen Haotong"],
    "审判四重奏-B": ["叶才阳", "唐雅莉", "方崎", "楚幂鹤", "殷弘", "陈浩桐"],
    "Quartet of Judgment-B": ["Ye Caiyang", "Tang Yali", "Fang Qi", "Chu Mihe", "Yin Hong", "Chen Haotong"],
//    "The Northern Song Mystery: Bianjing": ["Wu Yu", "Li Shishi", "Yang Yizhong", "Fan Yulou", "Wang Boyan", "Huang Qianshan"],
//    "The Sleepless Night of the Heads": ["Head 1", "Head 2", "Head 3", "Head 4", "Head 5", "Head 6"],
//    "The Eight Wonders of Water Mirror": ["Yuan Shao", "Lü Bu", "Jia Xu", "Xun Yu", "Zhang Fei", "Sun Jian", "Lady Zhen", "Sun Shangxiang"],
//    "All About Kichiya Kitahara": ["Hiroki Mukai", "Koichi Kiryu", "Yota Kyono", "Yuto Kanzaki", "Asuka Tsurumi", "Eri Karasawa"],
//    "Diary of a Split-Personality Boy": ["Diary 1", "Diary 2", "Diary 3", "Diary 4", "Diary 5", "Diary 6", "Diary 7"],
//    "Cat Island Murder Cycle": ["Rin Kisaragi", "Yui Kisaragi", "Kanata Hinata", "Yuin Hinata", "Juntarō Hoshikawa", "Maria Hoshikawa"],
//    "The Hawthorn Grove That Never Fades": ["Jin Ling", "Su Yue", "Qu Rong", "Zhou Yuan", "Chen Baiyang", "Chen Xiaohu", "Ma Sa"],
//    "The Tale of the Desert": ["Yizhi Yue", "Liu Zhiwan", "Yunqi", "Anchen", "Akona", "Princess Lan’an", "Ban Yi"],
//    "Cangqi": ["Xuanyuan Lingche", "Xuanyuan Mingsui", "Liu Qian", "Xiao Yuan", "Jun Tianli", "Lin Sirou"],
//    "70,000 Miles Homeward": ["Rong Kui", "Zhang Juanxin", "Yi Cheng", "Shen Yuezi", "Jin Yamei", "Huang Zuoting"],
//    "Rings of Time": ["Yuan Ben", "Chen Shuo", "Yao Bo", "Wang Xiaoran", "Liu Bozhao"],
//    "Moonlit Hollow": ["An Wu", "Erfu", "Wute", "Wu Aifei", "Reisi"],
//    "The Woman by the Window": ["Meng Qiuxue", "Prometheus", "The Caged Dove", "Gentlemanly Man", "Wuchang", "Black Mass"],
//    "The Soul Bell of Gu": ["Ye Meiniang", "Han Xiaotian", "Long Xiaowu", "Long Chengzhi", "Hua Yuelou", "Long Jinkun"]
];
let scriptOthers = [
//    "Shadows of Ashwick Manor": "4 Males 2 Females 1.5 Hours Advanced",
//    "Crimson Secrets on a Stormy Night": "4 Males 2 Females 1.5 Hours Intermediate",
    "审判四重奏-A": "4 Males 2 Females 1.5 Hours Intermediate",
    "Quartet of Judgment-A": "4 Males 2 Females 1.5 Hours Intermediate",
    "审判四重奏-B": "4 Males 2 Females 1.5 Hours Intermediate",
    "Quartet of Judgment-B": "4 Males 2 Females 1.5 Hours Intermediate",
//    "The Northern Song Mystery: Bianjing": "4 Males 2 Females 8.0 Hours Expert",
//    "The Sleepless Night of the Heads": "3 Males 3 Females 6.0 Hours Expert",
//    "The Eight Wonders of Water Mirror": "6 Males 2 Females 9.0 Hours Intermediate",
//    "All About Kichiya Kitahara": "4 Males 2 Females 6.0 Hours Intermediate",
//    "Diary of a Split-Personality Boy": "7 Males 0 Females 5.0 Hours Intermediate",
//    "Cat Island Murder Cycle": "3 Males 3 Females 8.0 Hours Expert",
//    "The Hawthorn Grove That Never Fades": "4 Males 3 Females 7.0 Hours Intermediate",
//    "The Tale of the Desert": "3 Males 4 Females 5.5 Hours Intermediate",
//    "Cangqi": "3 Males 3 Females 5.0 Hours Intermediate",
//    "70,000 Miles Homeward": "3 Males 3 Females 7.5 Hours Beginner",
//    "Rings of Time": "3 Males 2 Females 6.0 Hours Expert",
//    "Moonlit Hollow": "3 Males 2 Females 6.0 Hours Expert",
//    "The Woman by the Window": "4 Males 2 Females 4.0 Hours Beginner",
//    "The Soul Bell of Gu": "4 Males 2 Females 5.0 Hours Beginner"
];



class ScriptsLibraryController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return sriptsNames.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCellIdentifier, for: indexPath) as! ScriptsLibraryCellController
    
        // Configure the cell
        let imageName = sriptsNames[indexPath.item]
        let kindName = scriptsKinds[indexPath.item]
        let score = scriptsScores[indexPath.item]
        cell.imageView.image = UIImage(named: imageName)
        cell.nameLabel.text = imageName
        cell.kindLabel.text = kindName
        cell.scoreLabel.text = score
        
//        cell.backgroundColor = .gray
        cell.layer.cornerRadius = 10 // Adjust this value to change the corner radius
        cell.layer.masksToBounds = true // Ensure the subviews are also rounded
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader =  collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseSectionHeaderIdentifier, for: indexPath) as! SectionHeader
            sectionHeader.textLabel.text = "剧本库"
            return sectionHeader
        } else {
            return UICollectionReusableView()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showScriptDetail" {
            if let destinationVC = segue.destination as? ScriptsDetailController,
               let indexPath = collectionView.indexPathsForSelectedItems?.first {
                
                // 获取选中的剧本信息
                let scriptImageName = sriptsNames[indexPath.item]
                let scriptKind = scriptsKinds[indexPath.item]
                let scriptIntro = scriptIntros[scriptImageName]
                let scriptMember = scriptMembers[scriptImageName]
                let scriptOther = scriptOthers[scriptImageName]
                
                
                // 设置值给目标视图控制器
                destinationVC.scriptImage = UIImage(named: scriptImageName)
                destinationVC.scriptName = scriptImageName
                destinationVC.scriptKind = scriptKind
                destinationVC.scriptIntro = scriptIntro
                destinationVC.scriptMember = scriptMember
                destinationVC.scriptOther = scriptOther
            }
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
