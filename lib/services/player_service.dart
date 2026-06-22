import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/song.dart';
import '../models/recently_played.dart';
import '../models/artist.dart';
import 'firebase_auth_rest.dart';

String removeDiacritics(String str) {
  var withDiacritics = 'àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệđìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬÈÉẺẼẸÊỀẾỂỄỆĐÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴ';
  var withoutDiacritics = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeediiiiiooooooooooooooooouuuuuuuuuuuyyyyyAAAAAAAAAAAAAAAAAEEEEEEEEEEEDIIIIIOOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYY';
  
  String result = str;
  for (int i = 0; i < withDiacritics.length; i++) {
    result = result.replaceAll(withDiacritics[i], withoutDiacritics[i]);
  }
  return result;
}

class PlayerService extends ChangeNotifier {
  // Singleton pattern
  static final PlayerService _instance = PlayerService._internal();
  factory PlayerService() => _instance;
  PlayerService._internal() {
    _initAudioPlayer();
    loadProfile();
  }

  final List<Song> playlist = List.from(_defaultSongs);

  static const Map<String, String> _realCoverArts = {
    // Wren Evans
    "Từng Quen": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/9/4/b/b/94bb6e1a49dfb39d1b09b5585098ffb4.jpg",
    "Thích Em Hơi Nhiều": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/a/2/4/3/a243e887019c011409893d5084f7b445.jpg",
    "Call Me": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/d/3/4/2/d34202fb6f3e0c0b991b15ad824e4d58.jpg",
    "Cầu Vĩnh Tuy": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/8/9/a/7/89a744cb8dfb448f86f7cfb8793b8277.jpg",
    "Gặp May": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/d/b/2/2/db22055cbde774e1d74a7ee9b008d511.jpg",
    // tlinh
    "nếu lúc đó": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/d/e/2/e/de2e49c717013854eb130bc3409a2444.jpg",
    "ghệ iu dấu của em ơi": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/f/5/7/e/f57e841285223c93ee5c1a4030777558.jpg",
    "Gái Độc Thân": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/0/d/4/2/0d42646d6eb5b3d6d5ef664a7873ab06.jpg",
    "nữ siêu anh hùng": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/4/7/c/8/47c87c88bbfb2f9cd5830fb98a449bf7.jpg",
    "Không Cần Phải Nói Nhiều": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/6/2/c/8/62c8230b42f37c35a8d9a24c538cb339.jpg",
    // MCK
    "Chìm Sâu": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/a/d/4/4/ad44e05b5c92849e771c9cf41d2f954f.jpg",
    "Anh Đã Ổn Hơn": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/1/e/8/9/1e89de7ee7452d3d95cd7894a4c6cb7a.jpg",
    "Tại Vì Sao": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/6/0/6/f/606fbfdb9420bdae04cfb268b8e0f6b5.jpg",
    "Chỉ Một Đêm Nữa Thôi": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/3/b/a/b/3babf2bd1b8ec60f878b66804fb5b452.jpg",
    "Thôi Em Đừng Đi": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/8/a/6/9/8a698a3c5a6104dfdf442a8b9eb98fb4.jpg",
    // GREY D
    "đưa em về nhàa": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/b/5/d/3/b5d3a56cf9cbf78a4b419c72714fa4f3.jpg",
    "vaicaunoicokhiennguoithaydoi": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/2/2/4/6/22467d5817d23a101f3dbb7eb74548d8.jpg",
    "dự báo thời tiết hôm nay mưa": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/d/3/a/8/d3a8a3068e21a221f2022d4f24301cb2.jpg",
    "trái đất ôm mặt trời": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/0/b/1/e/0b1e19486c750b3e77f0a8c27f678ef4.jpg",
    "nhạt-fine": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/3/3/0/e/330e768e923d3876e5d0f1ec3c53b26c.jpg",
    // HIEUTHUHAI
    "Ngủ Một Mình": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/3/f/0/2/3f021cb50a37910ff66ee98059089cb1.jpg",
    "Không Thể Say": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/f/3/7/2/f372c3d1b87a87e45efc1c5cb5a2b724.jpg",
    "Vệ Tinh": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/a/2/b/6/a2b6672323ccb1f24d1a37c093a625a5.jpg",
    "Cua": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/1/a/1/e/1a1e0b5ab58ff40c7ff3b10b005470c1.jpg",
    "Giờ Thì Ai Cười": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/d/3/b/e/d3be3b72cb16016e75a3594e9f7831d1.jpg",
    // Sơn Tùng M-TP
    "Chúng Ta Của Tương Lai": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/5/d/f/a/5dfae70701026040842db13e5be56d77.jpg",
    "Muộn Rồi Mà Sao Còn": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/f/7/4/1/f74112e4f0d368e7ec89fcf276941b31.jpg",
    "Come My Way": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/1/e/d/b/1edb686e09e390c58e578ebc6d70ad84.jpg",
    "Có Chắc Yêu Là Đây": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/8/9/8/a/898a1a364be16a0c5c24e5261eb8fb4a.jpg",
    "Hãy Trao Cho Anh": "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/0/f/5/9/0f59c19b216cf29d0eb8d7a31b4007b3.jpg",
  };

  static const List<Song> _defaultSongs = [
    // 1. Wren Evans
    Song(
      title: "Từng Quen",
      artist: "Wren Evans",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/9/4/b/b/94bb6e1a49dfb39d1b09b5585098ffb4.jpg",
      bannerText: "Wren Evans",
      subtitle: "Wren Evans",
      themeColor: Color(0xFF5A1E29),
      lyrics: [
        "Nhìn ánh mắt của em anh cứ ngỡ là",
        "Ta đã từng quen, ta đã từng quen",
        "Cứ ngỡ là tình yêu nhưng lại là thói quen",
        "Làm con tim anh cứ thế rối ren.",
      ],
      audioUrl: "https://domain.com/tung-quen.mp3",
    ),
    Song(
      title: "Thích Em Hơi Nhiều",
      artist: "Wren Evans",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/a/2/4/3/a243e887019c011409893d5084f7b445.jpg",
      bannerText: "Wren Evans",
      subtitle: "Wren Evans",
      themeColor: Color(0xFF5A1E29),
      lyrics: [
        "Vì anh thích em hơi nhiều",
        "Nhưng mà chưa dám nói ra",
        "Sợ rằng em sẽ bước đi qua",
        "Để lại anh bơ vơ giữa phố đông.",
      ],
      audioUrl: "https://domain.com/thich-em-hoi-nhieu.mp3",
    ),
    Song(
      title: "Call Me",
      artist: "Wren Evans",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/d/3/4/2/d34202fb6f3e0c0b991b15ad824e4d58.jpg",
      bannerText: "Wren Evans",
      subtitle: "Wren Evans",
      themeColor: Color(0xFF5A1E29),
      lyrics: [
        "Call me if you need me",
        "Anh sẽ đến ngay thôi babe",
        "Chỉ cần em nhấc máy gọi tên anh",
        "Mọi muộn phiền sẽ tan biến nhanh.",
      ],
      audioUrl: "https://domain.com/call-me.mp3",
    ),
    Song(
      title: "Cầu Vĩnh Tuy",
      artist: "Wren Evans",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/8/9/a/7/89a744cb8dfb448f86f7cfb8793b8277.jpg",
      bannerText: "Wren Evans",
      subtitle: "Wren Evans",
      themeColor: Color(0xFF5A1E29),
      lyrics: [
        "Chạy xe qua cầu Vĩnh Tuy",
        "Gió đưa làn tóc em bay nhè nhẹ",
        "Nhớ những ngày đôi ta vẫn còn bên nhau",
        "Mà giờ đây chỉ còn lại nỗi sầu.",
      ],
      audioUrl: "https://domain.com/cau-vinh-tuy.mp3",
    ),
    Song(
      title: "Gặp May",
      artist: "Wren Evans",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/d/b/2/2/db22055cbde774e1d74a7ee9b008d511.jpg",
      bannerText: "Wren Evans",
      subtitle: "Wren Evans",
      themeColor: Color(0xFF5A1E29),
      lyrics: [
        "Có lẽ anh đã gặp may",
        "Khi vô tình thấy em trong chiều nay",
        "Nụ cười đó làm anh say đắm",
        "Muốn ôm em vào lòng thật chặt.",
      ],
      audioUrl: "https://domain.com/gap-may.mp3",
    ),

    // 2. tlinh
    Song(
      title: "nếu lúc đó",
      artist: "tlinh",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/d/e/2/e/de2e49c717013854eb130bc3409a2444.jpg",
      bannerText: "tlinh",
      subtitle: "tlinh",
      themeColor: Color(0xFF2E6B5E),
      lyrics: [
        "Nếu lúc đó em không buông tay",
        "Nếu lúc đó anh không lung lay",
        "Thì giờ đây ta đã có nhau",
        "Chẳng phải chịu những nỗi đau.",
      ],
      audioUrl: "https://domain.com/neu-luc-do.mp3",
    ),
    Song(
      title: "ghệ iu dấu của em ơi",
      artist: "tlinh",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/f/5/7/e/f57e841285223c93ee5c1a4030777558.jpg",
      bannerText: "tlinh",
      subtitle: "tlinh",
      themeColor: Color(0xFF2E6B5E),
      lyrics: [
        "Ghệ iu dấu của em ơi",
        "Đang làm gì đó, có nhớ em không",
        "Chỉ muốn chạy đến ôm anh một cái",
        "Cho thỏa nỗi nhớ mong.",
      ],
      audioUrl: "https://domain.com/ghe-iu-dau-cua-em-oi.mp3",
    ),
    Song(
      title: "Gái Độc Thân",
      artist: "tlinh",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/0/d/4/2/0d42646d6eb5b3d6d5ef664a7873ab06.jpg",
      bannerText: "tlinh",
      subtitle: "tlinh",
      themeColor: Color(0xFF2E6B5E),
      lyrics: [
        "Gái độc thân thì đã làm sao",
        "Vẫn cứ vui tươi, vẫn cứ tự hào",
        "Không cần ai đón đưa mỗi tối",
        "Tự mình làm chủ cuộc đời trôi.",
      ],
      audioUrl: "https://domain.com/gai-doc-than.mp3",
    ),
    Song(
      title: "nữ siêu anh hùng",
      artist: "tlinh",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/4/7/c/8/47c87c88bbfb2f9cd5830fb98a449bf7.jpg",
      bannerText: "tlinh",
      subtitle: "tlinh",
      themeColor: Color(0xFF2E6B5E),
      lyrics: [
        "Em sẽ là nữ siêu anh hùng",
        "Bảo vệ anh qua những giông bão",
        "Không để ai làm anh tổn thương",
        "Vì anh là người em yêu thương.",
      ],
      audioUrl: "https://domain.com/nu-sieu-anh-hung.mp3",
    ),
    Song(
      title: "Không Cần Phải Nói Nhiều",
      artist: "tlinh (ft. Hoàng Tôn)",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/6/2/c/8/62c8230b42f37c35a8d9a24c538cb339.jpg",
      bannerText: "tlinh",
      subtitle: "tlinh (ft. Hoàng Tôn)",
      themeColor: Color(0xFF2E6B5E),
      lyrics: [
        "Không cần phải nói nhiều",
        "Ánh mắt ta trao nhau đã hiểu",
        "Những cảm xúc đang dâng trào",
        "Trái tim này trao anh từ bao giờ.",
      ],
      audioUrl: "https://domain.com/khong-can-phai-noi-nhieu.mp3",
    ),

    // 3. MCK
    Song(
      title: "Chìm Sâu",
      artist: "MCK (ft. Trung Trần)",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/a/d/4/4/ad44e05b5c92849e771c9cf41d2f954f.jpg",
      bannerText: "MCK",
      subtitle: "MCK (ft. Trung Trần)",
      themeColor: Color(0xFF425664),
      lyrics: [
        "Vì em đã khiến anh chìm sâu",
        "Vào trong ánh mắt nụ cười ấy",
        "Anh không thể nào thoát ra được",
        "Cứ mãi tương tư về em thôi.",
      ],
      audioUrl: "https://domain.com/chim-sau.mp3",
    ),
    Song(
      title: "Anh Đã Ổn Hơn",
      artist: "MCK",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/1/e/8/9/1e89de7ee7452d3d95cd7894a4c6cb7a.jpg",
      bannerText: "MCK",
      subtitle: "MCK",
      themeColor: Color(0xFF425664),
      lyrics: [
        "Và anh đã ổn hơn",
        "Sau những đêm dài trằn trọc",
        "Không còn nhớ đến em nữa",
        "Trái tim này đã chai sạn rồi.",
      ],
      audioUrl: "https://domain.com/anh-da-on-hon.mp3",
    ),
    Song(
      title: "Tại Vì Sao",
      artist: "MCK",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/6/0/6/f/606fbfdb9420bdae04cfb268b8e0f6b5.jpg",
      bannerText: "MCK",
      subtitle: "MCK",
      themeColor: Color(0xFF425664),
      lyrics: [
        "Tại vì sao đôi ta lại chia xa",
        "Tại vì sao không thể cùng nhau bước qua",
        "Những giông bão của cuộc đời",
        "Để giờ đây chỉ còn lại nước mắt rơi.",
      ],
      audioUrl: "https://domain.com/tai-vi-sao.mp3",
    ),
    Song(
      title: "Chỉ Một Đêm Nữa Thôi",
      artist: "MCK (ft. tlinh)",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/3/b/a/b/3babf2bd1b8ec60f878b66804fb5b452.jpg",
      bannerText: "MCK",
      subtitle: "MCK (ft. tlinh)",
      themeColor: Color(0xFF425664),
      lyrics: [
        "Chỉ một đêm nữa thôi",
        "Cho ta được bên nhau",
        "Xóa tan mọi âu lo",
        "Hòa nhịp đập con tim.",
      ],
      audioUrl: "https://domain.com/chi-mot-dem-nua-thoi.mp3",
    ),
    Song(
      title: "Thôi Em Đừng Đi",
      artist: "MCK (ft. Trung Trần)",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/8/a/6/9/8a698a3c5a6104dfdf442a8b9eb98fb4.jpg",
      bannerText: "MCK",
      subtitle: "MCK (ft. Trung Trần)",
      themeColor: Color(0xFF425664),
      lyrics: [
        "Thôi em đừng đi, xin hãy ở lại",
        "Đừng để anh bơ vơ giữa đêm dài",
        "Anh cần em hơn bất cứ điều gì",
        "Đừng quay bước làm ngơ.",
      ],
      audioUrl: "https://domain.com/thoi-em-dung-di.mp3",
    ),

    // 4. GREY D
    Song(
      title: "đưa em về nhàa",
      artist: "GREY D (ft. Chillies)",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/b/5/d/3/b5d3a56cf9cbf78a4b419c72714fa4f3.jpg",
      bannerText: "GREY D",
      subtitle: "GREY D (ft. Chillies)",
      themeColor: Color(0xFF8F6B58),
      lyrics: [
        "Đưa em về nhà, mây trôi bềnh bồng",
        "Gió reo bên tai những lời thì thầm",
        "Quãng đường sao cứ ngắn lại",
        "Chỉ muốn đi mãi cùng em.",
      ],
      audioUrl: "https://domain.com/dua-em-ve-nhaa.mp3",
    ),
    Song(
      title: "vaicaunoicokhiennguoithaydoi",
      artist: "GREY D (ft. tlinh)",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/2/2/4/6/22467d5817d23a101f3dbb7eb74548d8.jpg",
      bannerText: "GREY D",
      subtitle: "GREY D (ft. tlinh)",
      themeColor: Color(0xFF8F6B58),
      lyrics: [
        "Vài câu nói có khiến người thay đổi",
        "Vài giọt nước mắt có làm vơi đi nỗi đau",
        "Chỉ biết lặng nhìn em bước đi",
        "Trái tim vỡ vụn thành từng mảnh.",
      ],
      audioUrl: "https://domain.com/vaicaunoicokhiennguoithaydoi.mp3",
    ),
    Song(
      title: "dự báo thời tiết hôm nay mưa",
      artist: "GREY D",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/d/3/a/8/d3a8a3068e21a221f2022d4f24301cb2.jpg",
      bannerText: "GREY D",
      subtitle: "GREY D",
      themeColor: Color(0xFF8F6B58),
      lyrics: [
        "Dự báo thời tiết hôm nay mưa",
        "Giống như tâm trạng anh lúc này",
        "Từng giọt mưa rơi tí tách",
        "Làm lòng anh thêm giá lạnh.",
      ],
      audioUrl: "https://domain.com/du-bao-thoi-tiet-hom-nay-mua.mp3",
    ),
    Song(
      title: "trái đất ôm mặt trời",
      artist: "GREY D x Kai Đinh x Hoàng Thùy Linh",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/0/b/1/e/0b1e19486c750b3e77f0a8c27f678ef4.jpg",
      bannerText: "GREY D",
      subtitle: "GREY D x Kai Đinh x Hoàng Thùy Linh",
      themeColor: Color(0xFF8F6B58),
      lyrics: [
        "Trái đất vẫn cứ xoay quanh mặt trời",
        "Như anh vẫn mãi hướng về em",
        "Dẫu cho khoảng cách có xa vời",
        "Tình yêu này vẫn không đổi dời.",
      ],
      audioUrl: "https://domain.com/trai-dat-om-mat-troi.mp3",
    ),
    Song(
      title: "nhạt-fine",
      artist: "GREY D",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/3/3/0/e/330e768e923d3876e5d0f1ec3c53b26c.jpg",
      bannerText: "GREY D",
      subtitle: "GREY D",
      themeColor: Color(0xFF8F6B58),
      lyrics: [
        "Tình yêu đôi ta nhạt phai",
        "Chẳng còn những đắm say",
        "Em nói em vẫn fine",
        "But trong lòng anh biết đang khóc.",
      ],
      audioUrl: "https://domain.com/nhat-fine.mp3",
    ),

    // 5. HIEUTHUHAI
    Song(
      title: "Ngủ Một Mình",
      artist: "HIEUTHUHAI (ft. Negav)",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/3/f/0/2/3f021cb50a37910ff66ee98059089cb1.jpg",
      bannerText: "HIEUTHUHAI",
      subtitle: "HIEUTHUHAI (ft. Negav)",
      themeColor: Color(0xFF2C3E50),
      lyrics: [
        "Anh không muốn phải ngủ một mình đêm nay",
        "Cần một ai đó ôm anh thật chặt",
        "Sưởi ấm con tim đang lạnh lẽo",
        "Cứ mãi cô đơn giữa căn phòng vắng.",
      ],
      audioUrl: "https://domain.com/ngu-mot-minh.mp3",
    ),
    Song(
      title: "Không Thể Say",
      artist: "HIEUTHUHAI",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/f/3/7/2/f372c3d1b87a87e45efc1c5cb5a2b724.jpg",
      bannerText: "HIEUTHUHAI",
      subtitle: "HIEUTHUHAI",
      themeColor: Color(0xFF2C3E50),
      lyrics: [
        "Dù uống bao nhiêu cũng không thể say",
        "Để quên đi hình bóng của em",
        "Từng ký ức cứ ùa về",
        "Làm anh không thể nào chợp mắt.",
      ],
      audioUrl: "https://domain.com/khong-the-say.mp3",
    ),
    Song(
      title: "Vệ Tinh",
      artist: "HIEUTHUHAI (ft. Hoàng Tôn)",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/a/2/b/6/a2b6672323ccb1f24d1a37c093a625a5.jpg",
      bannerText: "HIEUTHUHAI",
      subtitle: "HIEUTHUHAI (ft. Hoàng Tôn)",
      themeColor: Color(0xFF2C3E50),
      lyrics: [
        "Anh sẽ làm vệ tinh xoay quanh em",
        "Bảo vệ em khỏi những muộn phiền",
        "Chỉ cần em luôn nở nụ cười",
        "Mọi thứ khác cứ để anh lo.",
      ],
      audioUrl: "https://domain.com/ve-tinh.mp3",
    ),
    Song(
      title: "Cua",
      artist: "HIEUTHUHAI (ft. MANBO)",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/1/a/1/e/1a1e0b5ab58ff40c7ff3b10b005470c1.jpg",
      bannerText: "HIEUTHUHAI",
      subtitle: "HIEUTHUHAI (ft. MANBO)",
      themeColor: Color(0xFF2C3E50),
      lyrics: [
        "Đang lái xe trên con đường vắng",
        "Mở bài nhạc quen thuộc ta vẫn hay nghe",
        "Nhớ về những ngày tháng ấy",
        "Chẳng thể nào quên được đâu.",
      ],
      audioUrl: "https://domain.com/cua.mp3",
    ),
    Song(
      title: "Giờ Thì Ai Cười",
      artist: "HIEUTHUHAI",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/d/3/b/e/d3be3b72cb16016e75a3594e9f7831d1.jpg",
      bannerText: "HIEUTHUHAI",
      subtitle: "HIEUTHUHAI",
      themeColor: Color(0xFF2C3E50),
      lyrics: [
        "Giờ thì ai cười khi thấy anh thành công",
        "Những người đã từng khinh thường anh",
        "Đã đến lúc phải nhìn lại",
        "Anh đã vươn lên từ hai bàn tay trắng.",
      ],
      audioUrl: "https://domain.com/gio-thi-ai-cuoi.mp3",
    ),

    // 6. Sơn Tùng M-TP
    Song(
      title: "Chúng Ta Của Tương Lai",
      artist: "Sơn Tùng M-TP",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/5/d/f/a/5dfae70701026040842db13e5be56d77.jpg",
      bannerText: "Sơn Tùng M-TP",
      subtitle: "Sơn Tùng M-TP",
      themeColor: Color(0xFF4A2A5A),
      lyrics: [
        "Đừng tuyệt vọng em ơi",
        "Dù cho chặng đường có chơi vơi",
        "Tình yêu này vẫn luôn ở đây",
        "Đợi ngày mình lại nắm tay.",
      ],
      audioUrl: "https://domain.com/chung-ta-cua-tuong-lai.mp3",
    ),
    Song(
      title: "Muộn Rồi Mà Sao Còn",
      artist: "Sơn Tùng M-TP",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/f/7/4/1/f74112e4f0d368e7ec89fcf276941b31.jpg",
      bannerText: "Sơn Tùng M-TP",
      subtitle: "Sơn Tùng M-TP",
      themeColor: Color(0xFF4A2A5A),
      lyrics: [
        "Muộn rồi mà sao còn",
        "Nhìn lên trần nhà rồi quay ra",
        "Lại quay vào",
        "Nằm trằn trọc vậy đến sáng mai",
        "Ôm tương tư nụ cười của ai đó.",
      ],
      audioUrl: "https://domain.com/muon-roi-ma-sao-con.mp3",
    ),
    Song(
      title: "Come My Way",
      artist: "Sơn Tùng M-TP",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/1/e/d/b/1edb686e09e390c58e578ebc6d70ad84.jpg",
      bannerText: "Sơn Tùng M-TP",
      subtitle: "Sơn Tùng M-TP",
      themeColor: Color(0xFF4A2A5A),
      lyrics: [
        "You're breaking my heart",
        "You're tearing me apart",
        "But I'm making my way",
        "Making my way to you.",
      ],
      audioUrl: "https://domain.com/come-my-way.mp3",
    ),
    Song(
      title: "Có Chắc Yêu Là Đây",
      artist: "Sơn Tùng M-TP",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/8/9/8/a/898a1a364be16a0c5c24e5261eb8fb4a.jpg",
      bannerText: "Sơn Tùng M-TP",
      subtitle: "Sơn Tùng M-TP",
      themeColor: Color(0xFF4A2A5A),
      lyrics: [
        "Có chắc yêu là đây",
        "Tình yêu như phép nhiệm màu",
        "Gõ cửa trái tim anh",
        "Mang đến những nụ cười.",
      ],
      audioUrl: "https://domain.com/co-chac-yeu-la-day.mp3",
    ),
    Song(
      title: "Hãy Trao Cho Anh",
      artist: "Sơn Tùng M-TP (ft. Snoop Dogg)",
      albumArt: "https://photo-resize-zmp3.zmdcdn.me/w360_r1x1_jpeg/cover/0/f/5/9/0f59c19b216cf29d0eb8d7a31b4007b3.jpg",
      bannerText: "Sơn Tùng M-TP",
      subtitle: "Sơn Tùng M-TP (ft. Snoop Dogg)",
      themeColor: Color(0xFF4A2A5A),
      lyrics: [
        "Hãy trao cho anh",
        "Trao cho anh thứ tình yêu đắm say",
        "Trao cho anh nụ cười",
        "Xua tan đi những giá băng.",
      ],
      audioUrl: "https://domain.com/hay-trao-cho-anh.mp3",
    ),
  ];

  int _currentIndex = 0;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(minutes: 4);
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isShuffled = false;
  bool _isRepeating = false;

  // Profile data
  String _userName = "Văn Dương";
  String _userEmail = "admin@gmail.com";
  String _userPhone = "0909090909";
  String? _userImagePath;
  List<String> _savedAccounts = [];
  List<String> _registeredAccounts = [];
  String? _currentUid;

  List<RecentlyPlayedItem> _recentlyPlayedList = [];

  // Playlist & Liked data
  final List<String> _likedSongTitles = [];
  final List<String> _customPlaylists = [];
  final List<String> _downloadedSongTitles = [];
  final Map<String, List<String>> _playlistSongs = {}; // playlistName -> list of song titles
  final Map<String, String> _playlistCovers = {}; // playlistName -> local image path
  final List<Artist> _followedArtists = []; // Dynamic followed artists list

  // Getters
  Song get currentSong => playlist[_currentIndex];
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isShuffled => _isShuffled;
  bool get isRepeating => _isRepeating;

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    notifyListeners();
  }

  void toggleRepeating() {
    _isRepeating = !_isRepeating;
    notifyListeners();
  }

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String? get userImagePath => _userImagePath;
  String? get currentUid => _currentUid;
  bool get isLoggedIn => _currentUid != null;

  List<String> get likedSongTitles => _likedSongTitles;
  List<String> get customPlaylists => _customPlaylists;
  List<String> get downloadedSongTitles => _downloadedSongTitles;
  List<String> get savedAccounts => _savedAccounts;
  List<String> get registeredAccounts => _registeredAccounts;
  List<RecentlyPlayedItem> get recentlyPlayedList => _recentlyPlayedList;
  List<Artist> get followedArtists => _followedArtists;

  String getArtistImageUrl(String artistName, {String? fallbackUrl}) {
    final cleanArtistName = artistName.toLowerCase().trim();
    
    // 1. Try to find a song by this artist in the playlist that has a working (non-ZingMP3) URL
    try {
      final song = playlist.firstWhere(
        (s) => (s.artist.toLowerCase().contains(cleanArtistName) ||
                cleanArtistName.contains(s.artist.toLowerCase())) &&
               s.albumArt.isNotEmpty &&
               !s.albumArt.contains("zmdcdn.me") &&
               !s.albumArt.contains("photo-resize"),
      );
      return song.albumArt;
    } catch (_) {}
    
    // 2. If not found, try to find ANY song by this artist even if it's a ZingMP3 URL
    try {
      final song = playlist.firstWhere(
        (s) => (s.artist.toLowerCase().contains(cleanArtistName) ||
                cleanArtistName.contains(s.artist.toLowerCase())) &&
               s.albumArt.isNotEmpty,
      );
      return song.albumArt;
    } catch (_) {}
    
    // 3. Check followedArtists list
    try {
      final artist = _followedArtists.firstWhere(
        (a) => a.name.toLowerCase() == cleanArtistName,
      );
      if (artist.imageUrl.isNotEmpty) {
        return artist.imageUrl;
      }
    } catch (_) {}
    
    // 4. Fallback
    if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
      return fallbackUrl;
    }
    
    return "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80";
  }

  bool isSongDownloaded(String title) {
    return _downloadedSongTitles.contains(title);
  }

  Future<void> toggleDownloadSong(String title) async {
    if (_downloadedSongTitles.contains(title)) {
      _downloadedSongTitles.remove(title);
    } else {
      _downloadedSongTitles.add(title);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('downloaded_songs_${_currentUid ?? "guest"}', _downloadedSongTitles);
    notifyListeners();
  }

  void _initAudioPlayer() {
    _audioPlayer.onPositionChanged.listen((pos) {
      _currentPosition = pos;
      notifyListeners();
    }, onError: (err) {
      print("AudioPlayer Position Error: $err");
    }, cancelOnError: false);
    _audioPlayer.onDurationChanged.listen((dur) {
      _totalDuration = dur;
      notifyListeners();
    }, onError: (err) {
      print("AudioPlayer Duration Error: $err");
    }, cancelOnError: false);
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    }, onError: (err) {
      print("AudioPlayer State Error: $err");
      _isPlaying = false;
      notifyListeners();
    }, cancelOnError: false);
    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isRepeating) {
        _currentPosition = Duration.zero;
        _safePlay(currentSong.audioUrl);
        notifyListeners();
      } else {
        next();
      }
    }, onError: (err) {
      print("AudioPlayer Complete Error: $err");
      _isPlaying = false;
      notifyListeners();
    }, cancelOnError: false);
  }

  /// Tạo lại audio player sau khi bị lỗi native
  void _resetAudioPlayer() {
    try {
      _audioPlayer.dispose();
    } catch (_) {}
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
    _isPlaying = false;
    notifyListeners();
  }

  // Load profile, custom playlists and liked songs from SharedPreferences & Firestore
  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // Load playlist dynamically from Firestore songs collection
    try {
      final songsSnapshot = await FirebaseFirestore.instance.collection('songs').get();
      
      bool needsSeeding = songsSnapshot.docs.isEmpty;

      playlist.clear();
      if (!needsSeeding) {
        final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> groupedSongs = {};
        for (final doc in songsSnapshot.docs) {
          final data = doc.data();
          final titleStr = (data['title'] ?? '').toString().trim().toLowerCase();
          final artistStr = (data['artist'] ?? '').toString().trim().toLowerCase();
          final key = "$titleStr|$artistStr";
          groupedSongs.putIfAbsent(key, () => []).add(doc);
        }

        for (final key in groupedSongs.keys) {
          final docs = groupedSongs[key]!;
          QueryDocumentSnapshot<Map<String, dynamic>> keepDoc = docs.first;

          if (docs.length > 1) {
            // Find the best one (prefer non-empty, non-unsplash, valid URL)
            for (final doc in docs) {
              final data = doc.data();
              final albumArtStr = (data['albumArt'] ?? '').toString().trim();
              if (albumArtStr.isNotEmpty &&
                  albumArtStr.startsWith('http') &&
                  !albumArtStr.contains('unsplash.com')) {
                keepDoc = doc;
                break;
              }
            }

            // Delete the duplicates from Firestore
            for (final doc in docs) {
              if (doc.id != keepDoc.id) {
                FirebaseFirestore.instance.collection('songs').doc(doc.id).delete().catchError((e) {
                  print("Error deleting duplicate song doc ${doc.id}: $e");
                });
              }
            }
          }

          final data = keepDoc.data();
          final titleStr = (data['title'] ?? '').toString().trim();
          String albumArtStr = (data['albumArt'] ?? '').toString().trim();
          if (albumArtStr.contains("domain.com") && _realCoverArts.containsKey(titleStr)) {
            albumArtStr = _realCoverArts[titleStr]!;
          }

          playlist.add(Song(
            title: titleStr,
            artist: (data['artist'] ?? '').toString().trim(),
            albumArt: albumArtStr,
            bannerText: (data['bannerText'] ?? '').toString().trim(),
            subtitle: (data['subtitle'] ?? '').toString().trim(),
            themeColor: Color(int.parse(data['themeColor'] ?? '0xFF1E293B')),
            lyrics: List<String>.from(data['lyrics'] ?? []),
            audioUrl: (data['audioUrl'] ?? '').toString().trim(),
          ));
        }
      } else {
        // Seed default songs into Firestore
        for (int i = 0; i < _defaultSongs.length; i++) {
          final song = _defaultSongs[i];
          final docId = "song_${i + 1}";
          await FirebaseFirestore.instance.collection('songs').doc(docId).set({
            'title': song.title,
            'artist': song.artist,
            'albumArt': song.albumArt,
            'bannerText': song.bannerText,
            'subtitle': song.subtitle,
            'themeColor': '0x' + song.themeColor.value.toRadixString(16).toUpperCase(),
            'lyrics': song.lyrics,
            'audioUrl': song.audioUrl,
          });
          playlist.add(song);
        }
      }
    } catch (e) {
      print("Error loading/seeding Firestore songs: $e");
      // Fallback to default list
      playlist.clear();
      playlist.addAll(_defaultSongs);
    }

    // Load active logged-in accounts on device for switcher
    _savedAccounts = prefs.getStringList('saved_accounts') ?? [];
    if (_savedAccounts.isEmpty) {
      final defaultAcc = "Văn Dương|admin@gmail.com|0909090909|null|123456";
      _savedAccounts.add(defaultAcc);
      await prefs.setStringList('saved_accounts', _savedAccounts);
    }

    // Load uid from local storage (set during login/register via REST API)
    _currentUid = prefs.getString('current_uid');
    if (_currentUid == null) {
      _userName = "Văn Dương";
      _userEmail = "admin@gmail.com";
      _userPhone = "0909090909";
      _userImagePath = null;
      notifyListeners();
      return;
    }

    final uid = _currentUid!;

    try {
      // 1. Fetch user document from Firestore
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
     if (userDoc.exists) {
       final data = userDoc.data()!;
       _userName = data['name'] ?? 'Văn Dương';
       _userEmail = data['email'] ?? 'admin@gmail.com';
       _userPhone = data['phone'] ?? '0909090909';
       final path = data['imagePath'];
       _userImagePath = (path == "null" || path == null) ? null : path;

       // Automatically sync SharedPreferences saved accounts list with Firestore profile info
       bool updatedSaved = false;
       for (int i = 0; i < _savedAccounts.length; i++) {
         final parts = _savedAccounts[i].split('|');
         if (parts.length >= 2 && parts[1].toLowerCase() == _userEmail.toLowerCase()) {
           final password = parts.length >= 5 ? parts[4] : "123456";
           _savedAccounts[i] = "$_userName|$_userEmail|$_userPhone|${_userImagePath ?? 'null'}|$password";
           updatedSaved = true;
           break;
         }
       }
       if (updatedSaved) {
         await prefs.setStringList('saved_accounts', _savedAccounts);
       }
     } else {
      _userName = "Người dùng";
      _userEmail = "";
      _userPhone = "0909090909";
      _userImagePath = null;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _userName,
        'email': _userEmail,
        'phone': _userPhone,
        'imagePath': null,
      });
    }

    // 2. Fetch user's liked songs from Firestore
    final likesDoc = await FirebaseFirestore.instance.collection('likes').doc(uid).get();
    _likedSongTitles.clear();
    if (likesDoc.exists) {
      final List<dynamic> titles = likesDoc.data()?['songTitles'] ?? [];
      _likedSongTitles.addAll(titles.cast<String>());
    }

    // 3. Fetch user's custom playlists from Firestore
    final playlistsDoc = await FirebaseFirestore.instance.collection('playlists').doc(uid).get();
    _customPlaylists.clear();
    if (playlistsDoc.exists) {
      final List<dynamic> playlists = playlistsDoc.data()?['names'] ?? [];
      _customPlaylists.addAll(playlists.cast<String>());
    }

    // 3b. Fetch playlist songs associations from Firestore
    _playlistSongs.clear();
    try {
      final playlistSongsDoc = await FirebaseFirestore.instance.collection('playlist_songs').doc(uid).get();
      if (playlistSongsDoc.exists) {
        final data = playlistSongsDoc.data()!;
        for (final key in data.keys) {
          _playlistSongs[key] = List<String>.from(data[key] ?? []);
        }
      }
    } catch (e) {
      print("Error loading playlist songs: $e");
    }
    // Initialize empty lists for playlists without songs data
    for (final name in _customPlaylists) {
      if (!_playlistSongs.containsKey(name)) {
        _playlistSongs[name] = [];
      }
    }

    // 3c. Fetch playlist covers from Firestore
    _playlistCovers.clear();
    try {
      final playlistCoversDoc = await FirebaseFirestore.instance.collection('playlist_covers').doc(uid).get();
      if (playlistCoversDoc.exists) {
        final data = playlistCoversDoc.data()!;
        for (final key in data.keys) {
          _playlistCovers[key] = data[key]?.toString() ?? "";
        }
      }
    } catch (e) {
      print("Error loading playlist covers: $e");
    }

    // 3d. Fetch user's followed artists from Firestore
    _followedArtists.clear();
    try {
      final artistsDoc = await FirebaseFirestore.instance.collection('followed_artists').doc(uid).get();
      if (artistsDoc.exists) {
        final List<dynamic> list = artistsDoc.data()?['artists'] ?? [];
        _followedArtists.addAll(list.map((x) => Artist.fromJson(x)));
      } else {
        // Seed default artists
        _followedArtists.addAll([
          const Artist(
            name: "Sơn Tùng M-TP",
            imageUrl: "https://photo-resize-zmp3.zmdcdn.me/w600_r1x1_jpeg/covers/c/b/cb659c049b4bd8e32c8644558e0a3eb7_1487000305.jpg",
          ),
          const Artist(
            name: "HIEUTHUHAI",
            imageUrl: "https://i.scdn.co/image/ab67706f000000028a42b918f0ee0e816a7bf571",
          ),
          const Artist(
            name: "Wren Evans",
            imageUrl: "https://i.scdn.co/image/ab6761610000e5ebd8f1618a8f1fb40474328328",
          ),
        ]);
        await FirebaseFirestore.instance.collection('followed_artists').doc(uid).set({
          'artists': _followedArtists.map((x) => x.toJson()).toList(),
        });
      }
    } catch (e) {
      print("Error loading followed artists: $e");
    }

    // 4. Fetch user's recently played from Firestore
    final recentDoc = await FirebaseFirestore.instance.collection('recently_played').doc(uid).get();
    _recentlyPlayedList.clear();
    if (recentDoc.exists) {
      final List<dynamic> savedRecent = recentDoc.data()?['items'] ?? [];
      _recentlyPlayedList.addAll(savedRecent.map((s) => RecentlyPlayedItem.fromJson(s)));
    } else {
      // Seed with mock recently played items as shown in screenshot
      final mockDate1 = DateTime(2026, 6, 13, 15, 30);
      final mockDate2 = DateTime(2026, 6, 10, 11, 20);
      final mockDate3 = DateTime(2026, 6, 9, 9, 45);

      _recentlyPlayedList.addAll([
        RecentlyPlayedItem(
          title: "Sơn Tùng M-TP",
          subtitle: "Đã phát 1 bài hát • Nghệ sĩ",
          imageUrl: "https://photo-resize-zmp3.zmdcdn.me/w600_r1x1_jpeg/covers/c/b/cb659c049b4bd8e32c8644558e0a3eb7_1487000305.jpg",
          type: "artist",
          playedAt: mockDate1,
          details: "Đã phát 1 bài hát",
        ),
        RecentlyPlayedItem(
          title: "Sơn Tùng M-TP",
          subtitle: "Đã phát 5 bài hát • Nghệ sĩ",
          imageUrl: "https://photo-resize-zmp3.zmdcdn.me/w600_r1x1_jpeg/covers/c/b/cb659c049b4bd8e32c8644558e0a3eb7_1487000305.jpg",
          type: "artist",
          playedAt: mockDate2,
          details: "Đã phát 5 bài hát",
        ),
        RecentlyPlayedItem(
          title: "Sơn Tùng M-TP",
          subtitle: "Đã phát 11 bài hát • Nghệ sĩ",
          imageUrl: "https://photo-resize-zmp3.zmdcdn.me/w600_r1x1_jpeg/covers/c/b/cb659c049b4bd8e32c8644558e0a3eb7_1487000305.jpg",
          type: "artist",
          playedAt: mockDate3,
          details: "Đã phát 11 bài hát",
        ),
        RecentlyPlayedItem(
          title: "Nhạc của đá",
          subtitle: "Danh sách phát • Dương Quá",
          imageUrl: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80",
          type: "playlist",
          playedAt: mockDate3,
          details: "Danh sách phát",
          creator: "Dương Quá",
          hasCheck: true,
        ),
        RecentlyPlayedItem(
          title: "Sơn Tùng M-TP Radio",
          subtitle: "Đã phát 32 bài hát • Danh sách phát • Spotify",
          imageUrl: "https://photo-resize-zmp3.zmdcdn.me/w600_r1x1_jpeg/covers/c/b/cb659c049b4bd8e32c8644558e0a3eb7_1487000305.jpg",
          type: "radio",
          playedAt: mockDate3,
          details: "Đã phát 32 bài hát • Danh sách phát",
          creator: "Spotify",
        ),
        RecentlyPlayedItem(
          title: "Người Im Lặng Gặp Người Hay Nói Radio",
          subtitle: "Đã phát 19 bài hát • Danh sách phát • Spotify",
          imageUrl: "https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=400&q=80",
          type: "radio",
          playedAt: mockDate3,
          details: "Đã phát 19 bài hát • Danh sách phát",
          creator: "Spotify",
        ),
      ]);
      await FirebaseFirestore.instance.collection('recently_played').doc(uid).set({
        'items': _recentlyPlayedList.map((item) => item.toJson()).toList(),
      });
    }
    } catch (e) {
      print("Firebase database load failure: $e. Reverting to local fallback data.");
      _userName = prefs.getString('local_user_name') ?? "Văn Dương";
      _userEmail = prefs.getString('local_user_email') ?? "admin@gmail.com";
      _userPhone = prefs.getString('local_user_phone') ?? "0909090909";
      _userImagePath = null;
      if (_followedArtists.isEmpty) {
        _followedArtists.addAll([
          const Artist(
            name: "Sơn Tùng M-TP",
            imageUrl: "https://photo-resize-zmp3.zmdcdn.me/w600_r1x1_jpeg/covers/c/b/cb659c049b4bd8e32c8644558e0a3eb7_1487000305.jpg",
          ),
          const Artist(
            name: "HIEUTHUHAI",
            imageUrl: "https://i.scdn.co/image/ab67706f000000028a42b918f0ee0e816a7bf571",
          ),
          const Artist(
            name: "Wren Evans",
            imageUrl: "https://i.scdn.co/image/ab6761610000e5ebd8f1618a8f1fb40474328328",
          ),
        ]);
      }
    }

    // 5. Fetch user's local downloads list
    final List<String> savedDownloads = prefs.getStringList('downloaded_songs_$uid') ?? [];
    _downloadedSongTitles.clear();
    _downloadedSongTitles.addAll(savedDownloads);

    notifyListeners();
  }

  // Update profile details inside both active variables and databases
  Future<void> updateProfile(String name, String email, String phone, String? imagePath) async {
    if (_currentUid == null) return;

    final uid = _currentUid!;
    final oldEmail = _userEmail;
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    _userImagePath = imagePath;

    // 1. Update Firestore user document
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': name,
        'email': email,
        'phone': phone,
        'imagePath': imagePath ?? 'null',
      });
    } catch (e) {
      print("Error updating profile in Firestore: $e");
    }

    // 2. Update saved_accounts list locally for the switcher
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < _savedAccounts.length; i++) {
      final parts = _savedAccounts[i].split('|');
      if (parts.length >= 2 && parts[1].toLowerCase() == oldEmail.toLowerCase()) {
        final password = parts.length >= 5 ? parts[4] : "123456";
        _savedAccounts[i] = "$name|$email|$phone|${imagePath ?? 'null'}|$password";
        break;
      }
    }
    await prefs.setStringList('saved_accounts', _savedAccounts);

    notifyListeners();
  }

  // Register a new user inside Firebase Auth REST API and Firestore
  Future<String?> registerUser(String name, String email, String phone, String password) async {
    try {
      final result = await FirebaseAuthRest.signUp(email: email, password: password);
      final uid = result['localId'] as String;

      // Save uid locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_uid', uid);
      _currentUid = uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'imagePath': null,
      });

      // Add to saved_accounts in SharedPreferences for device switcher
      final newRecord = "$name|$email|$phone|null|$password";
      _savedAccounts.add(newRecord);
      await prefs.setStringList('saved_accounts', _savedAccounts);

      await loadProfile();
      await prefs.setBool('user_logged_in', true);
      return null; // success
    } on FirebaseAuthRestException catch (e) {
      print("Firebase Register Error: $e");
      return e.message;
    } catch (e) {
      print("Firebase Register Error: $e");
      return e.toString();
    }
  }

  // Validate login details via REST API, switch session on success, and add to drawer list
  Future<String?> loginUser(String email, String password) async {
    try {
      final result = await FirebaseAuthRest.signIn(email: email, password: password);
      final uid = result['localId'] as String;

      // Save uid locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_uid', uid);
      _currentUid = uid;

      // Fetch user data from Firestore to save locally in switcher list
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String name = "Người dùng";
      String phone = "0909090909";
      String? imagePath;
      if (userDoc.exists) {
        final data = userDoc.data()!;
        name = data['name'] ?? name;
        phone = data['phone'] ?? phone;
        imagePath = data['imagePath'];
      }

      bool existsInSaved = false;
      for (final accStr in _savedAccounts) {
        final parts = accStr.split('|');
        if (parts.length >= 2 && parts[1].toLowerCase() == email.toLowerCase()) {
          existsInSaved = true;
          break;
        }
      }
      
      if (!existsInSaved) {
        final newRecord = "$name|$email|$phone|${imagePath ?? 'null'}|$password";
        _savedAccounts.add(newRecord);
        await prefs.setStringList('saved_accounts', _savedAccounts);
      }

      await loadProfile();
      await prefs.setBool('user_logged_in', true);
      return null; // success
    } on FirebaseAuthRestException catch (e) {
      return e.message;
    } catch (e) {
      return "Lỗi kết nối hệ thống!";
    }
  }

  // Send a password reset email using FirebaseAuthRest
  Future<String?> sendPasswordReset(String email) async {
    try {
      await FirebaseAuthRest.sendPasswordResetEmail(email: email);
      return null; // success
    } on FirebaseAuthRestException catch (e) {
      return e.message;
    } catch (e) {
      return "Lỗi kết nối hệ thống!";
    }
  }

  // Re-authenticate and change password for the current user.
  // Updates local saved_accounts list to keep the new password sync.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (_userEmail.isEmpty) {
        return "Không tìm thấy thông tin email của tài khoản!";
      }

      // Step 1: Re-authenticate to get a fresh idToken
      final signInResult = await FirebaseAuthRest.signIn(
        email: _userEmail,
        password: currentPassword,
      );
      final idToken = signInResult['idToken'] as String;

      // Step 2: Update the password on Firebase
      await FirebaseAuthRest.updatePassword(
        idToken: idToken,
        newPassword: newPassword,
      );

      // Step 3: Update local SharedPreferences saved_accounts list
      final prefs = await SharedPreferences.getInstance();
      for (int i = 0; i < _savedAccounts.length; i++) {
        final parts = _savedAccounts[i].split('|');
        if (parts.length >= 2 && parts[1].toLowerCase() == _userEmail.toLowerCase()) {
          final name = parts[0];
          final email = parts[1];
          final phone = parts[2];
          final img = parts.length >= 4 ? parts[3] : 'null';
          _savedAccounts[i] = "$name|$email|$phone|$img|$newPassword";
          break;
        }
      }
      await prefs.setStringList('saved_accounts', _savedAccounts);
      notifyListeners();

      return null; // success
    } on FirebaseAuthRestException catch (e) {
      return e.message;
    } catch (e) {
      return "Lỗi kết nối hệ thống!";
    }
  }

  // Re-authenticate and delete the current user account from Firebase and Firestore.
  Future<String?> deleteAccount({
    required String password,
  }) async {
    try {
      if (_userEmail.isEmpty) {
        return "Không tìm thấy thông tin email của tài khoản!";
      }

      // Step 1: Re-authenticate to get a fresh idToken
      final signInResult = await FirebaseAuthRest.signIn(
        email: _userEmail,
        password: password,
      );
      final idToken = signInResult['idToken'] as String;
      final uid = _currentUid;

      // Step 2: Delete user from Firebase Auth
      await FirebaseAuthRest.deleteAccount(idToken: idToken);

      // Step 3: Remove user document and other data from Firestore (best effort/optional but clean)
      if (uid != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(uid).delete();
          await FirebaseFirestore.instance.collection('likes').doc(uid).delete();
          await FirebaseFirestore.instance.collection('playlists').doc(uid).delete();
          await FirebaseFirestore.instance.collection('playlist_songs').doc(uid).delete();
          await FirebaseFirestore.instance.collection('playlist_covers').doc(uid).delete();
          await FirebaseFirestore.instance.collection('followed_artists').doc(uid).delete();
          await FirebaseFirestore.instance.collection('recently_played').doc(uid).delete();
        } catch (e) {
          print("Error cleaning up Firestore data for deleted user: $e");
        }
      }

      // Step 4: Remove account from SharedPreferences saved accounts list
      final emailToDelete = _userEmail;
      final prefs = await SharedPreferences.getInstance();
      _savedAccounts.removeWhere((accStr) {
        final parts = accStr.split('|');
        return parts.length >= 2 && parts[1].toLowerCase() == emailToDelete.toLowerCase();
      });
      await prefs.setStringList('saved_accounts', _savedAccounts);

      // Step 5: Log out / reset state
      await prefs.setBool('user_logged_in', false);
      await prefs.remove('current_uid');
      pause();
      
      _currentUid = null;
      _userName = "Người dùng";
      _userEmail = "";
      _userPhone = "0909090909";
      _userImagePath = null;
      _likedSongTitles.clear();
      _customPlaylists.clear();
      _playlistSongs.clear();
      _playlistCovers.clear();
      _followedArtists.clear();
      _recentlyPlayedList.clear();

      notifyListeners();

      return null; // success
    } on FirebaseAuthRestException catch (e) {
      return e.message;
    } catch (e) {
      return "Lỗi kết nối hệ thống!";
    }
  }


  // Add a new account directly to switcher list (mostly for automated add triggers)
  Future<void> addAccount(String name, String email, String phone, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    bool exists = false;
    for (final accStr in _savedAccounts) {
      final parts = accStr.split('|');
      if (parts.length >= 2 && parts[1].toLowerCase() == email.toLowerCase()) {
        exists = true;
        break;
      }
    }
    
    if (!exists) {
      final newRecord = "$name|$email|$phone|null|$password";
      _savedAccounts.add(newRecord);
      await prefs.setStringList('saved_accounts', _savedAccounts);
    }
    
    await switchAccount(email);
  }

  // Switch active session
  Future<void> switchAccount(String email) async {
    for (final accStr in _savedAccounts) {
      final parts = accStr.split('|');
      if (parts.length >= 2 && parts[1].toLowerCase() == email.toLowerCase()) {
        final password = parts.length >= 5 ? parts[4] : "123456";
        
        try {
          final result = await FirebaseAuthRest.signIn(email: email, password: password);
          final uid = result['localId'] as String;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_uid', uid);
          _currentUid = uid;
        } catch (e) {
          print("Switch session Firebase signin failed: $e");
        }

        await loadProfile();
        break;
      }
    }
  }

  // Remove account from switcher list
  Future<void> removeAccount(String email) async {
    final prefs = await SharedPreferences.getInstance();
    
    int indexToRemove = -1;
    for (int i = 0; i < _savedAccounts.length; i++) {
      final parts = _savedAccounts[i].split('|');
      if (parts.length >= 2 && parts[1].toLowerCase() == email.toLowerCase()) {
        indexToRemove = i;
        break;
      }
    }
    
    if (indexToRemove != -1) {
      _savedAccounts.removeAt(indexToRemove);
      await prefs.setStringList('saved_accounts', _savedAccounts);
      
      if (_userEmail == email && _savedAccounts.isNotEmpty) {
        final firstParts = _savedAccounts.first.split('|');
        await switchAccount(firstParts[1]);
      } else if (_savedAccounts.isEmpty) {
        final defaultAcc = "Văn Dương|admin@gmail.com|0909090909|null";
        _savedAccounts.add(defaultAcc);
        await prefs.setStringList('saved_accounts', _savedAccounts);
        await switchAccount("admin@gmail.com");
      }
      notifyListeners();
    }
  }

  // Toggle Song Like
  Future<void> toggleLikeSong(Song song) async {
    if (_currentUid == null) return;

    if (_likedSongTitles.contains(song.title)) {
      _likedSongTitles.remove(song.title);
    } else {
      _likedSongTitles.add(song.title);
    }

    try {
      await FirebaseFirestore.instance.collection('likes').doc(_currentUid!).set({
        'songTitles': _likedSongTitles,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error updating likes in Firestore: $e");
    }

    notifyListeners();
  }

  bool isSongLiked(Song song) {
    return _likedSongTitles.contains(song.title);
  }

  // Add Custom Playlist
  Future<void> addCustomPlaylist(String name) async {
    if (_currentUid == null) return;

    if (!_customPlaylists.contains(name)) {
      _customPlaylists.add(name);
      _playlistSongs[name] = [];
      try {
        await FirebaseFirestore.instance.collection('playlists').doc(_currentUid!).set({
          'names': _customPlaylists,
        }, SetOptions(merge: true));
      } catch (e) {
        print("Error saving playlist in Firestore: $e");
      }
      notifyListeners();
    }
  }

  // Get songs in a playlist
  List<Song> getPlaylistSongs(String playlistName) {
    final titles = _playlistSongs[playlistName] ?? [];
    return playlist.where((s) => titles.contains(s.title)).toList();
  }

  // Add song to a playlist
  Future<void> addSongToPlaylist(String playlistName, String songTitle) async {
    if (_currentUid == null) return;
    if (!_playlistSongs.containsKey(playlistName)) {
      _playlistSongs[playlistName] = [];
    }
    if (!_playlistSongs[playlistName]!.contains(songTitle)) {
      _playlistSongs[playlistName]!.add(songTitle);
      notifyListeners();
      try {
        await FirebaseFirestore.instance.collection('playlist_songs').doc(_currentUid!).set({
          playlistName: _playlistSongs[playlistName],
        }, SetOptions(merge: true));
      } catch (e) {
        print("Error saving playlist songs: $e");
      }
    }
  }

  // Remove song from a playlist
  Future<void> removeSongFromPlaylist(String playlistName, String songTitle) async {
    if (_currentUid == null) return;
    _playlistSongs[playlistName]?.remove(songTitle);
    notifyListeners();
    try {
      await FirebaseFirestore.instance.collection('playlist_songs').doc(_currentUid!).set({
        playlistName: _playlistSongs[playlistName] ?? [],
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error saving playlist songs: $e");
    }
  }

  // Check if song is in playlist
  bool isSongInPlaylist(String playlistName, String songTitle) {
    return _playlistSongs[playlistName]?.contains(songTitle) ?? false;
  }

  // Delete Custom Playlist
  Future<void> deleteCustomPlaylist(String name) async {
    if (_currentUid == null) return;

    _customPlaylists.remove(name);
    _playlistCovers.remove(name);
    _playlistSongs.remove(name);

    try {
      await FirebaseFirestore.instance.collection('playlists').doc(_currentUid!).set({
        'names': _customPlaylists,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error deleting playlist document in Firestore: $e");
    }

    try {
      await FirebaseFirestore.instance.collection('playlist_covers').doc(_currentUid!).update({
        name: FieldValue.delete(),
      });
    } catch (e) {
      print("Error deleting playlist cover: $e");
    }

    try {
      await FirebaseFirestore.instance.collection('playlist_songs').doc(_currentUid!).update({
        name: FieldValue.delete(),
      });
    } catch (e) {
      print("Error deleting playlist songs: $e");
    }

    notifyListeners();
  }

  // Get custom cover image for a playlist
  String? getPlaylistCover(String playlistName) {
    final path = _playlistCovers[playlistName];
    if (path == null || path.isEmpty) return null;
    return path;
  }

  // Set custom cover image for a playlist
  Future<void> setPlaylistCover(String playlistName, String imagePath) async {
    if (_currentUid == null) return;
    _playlistCovers[playlistName] = imagePath;
    notifyListeners();
    try {
      await FirebaseFirestore.instance.collection('playlist_covers').doc(_currentUid!).set({
        playlistName: imagePath,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error saving playlist cover: $e");
    }
  }

  // Rename Custom Playlist
  Future<void> renameCustomPlaylist(String oldName, String newName) async {
    if (_currentUid == null || oldName == newName || newName.trim().isEmpty) return;

    final index = _customPlaylists.indexOf(oldName);
    if (index != -1) {
      _customPlaylists[index] = newName;
    }

    // Move cover mapping
    if (_playlistCovers.containsKey(oldName)) {
      _playlistCovers[newName] = _playlistCovers[oldName]!;
      _playlistCovers.remove(oldName);
    }

    // Move playlist songs mapping
    if (_playlistSongs.containsKey(oldName)) {
      _playlistSongs[newName] = _playlistSongs[oldName]!;
      _playlistSongs.remove(oldName);
    }

    notifyListeners();

    // Firestore updates
    try {
      await FirebaseFirestore.instance.collection('playlists').doc(_currentUid!).set({
        'names': _customPlaylists,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error renaming playlist document: $e");
    }

    try {
      await FirebaseFirestore.instance.collection('playlist_covers').doc(_currentUid!).set({
        oldName: FieldValue.delete(),
        newName: _playlistCovers[newName] ?? "",
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error renaming playlist cover document: $e");
    }

    try {
      await FirebaseFirestore.instance.collection('playlist_songs').doc(_currentUid!).set({
        oldName: FieldValue.delete(),
        newName: _playlistSongs[newName] ?? [],
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error renaming playlist songs document: $e");
    }
  }

  // Add Followed Artist
  Future<void> addFollowedArtist(String name, String imageUrl) async {
    if (_currentUid == null || name.trim().isEmpty) return;

    final artist = Artist(name: name, imageUrl: imageUrl);
    _followedArtists.add(artist);
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('followed_artists').doc(_currentUid!).set({
        'artists': _followedArtists.map((x) => x.toJson()).toList(),
      });
    } catch (e) {
      print("Error adding followed artist: $e");
    }
  }

  // Update Followed Artist
  Future<void> updateFollowedArtist(String oldName, String newName, String newImageUrl) async {
    if (_currentUid == null || newName.trim().isEmpty) return;

    final index = _followedArtists.indexWhere((x) => x.name == oldName);
    if (index != -1) {
      _followedArtists[index] = Artist(name: newName, imageUrl: newImageUrl);
      notifyListeners();

      try {
        await FirebaseFirestore.instance.collection('followed_artists').doc(_currentUid!).set({
          'artists': _followedArtists.map((x) => x.toJson()).toList(),
        });
      } catch (e) {
        print("Error updating followed artist: $e");
      }
    }
  }

  // Remove Followed Artist
  Future<void> removeFollowedArtist(String name) async {
    if (_currentUid == null) return;

    _followedArtists.removeWhere((x) => x.name == name);
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('followed_artists').doc(_currentUid!).set({
        'artists': _followedArtists.map((x) => x.toJson()).toList(),
      });
    } catch (e) {
      print("Error removing followed artist: $e");
    }
  }


  // Dynamic Search function
  List<Song> searchSongs(String query) {
    if (query.trim().isEmpty) return [];
    
    final normalizedQuery = removeDiacritics(query.toLowerCase().trim());
    
    // Check if it matches a category query
    if (normalizedQuery == "nhac viet") {
      return playlist;
    } else if (normalizedQuery == "k-pop" || normalizedQuery == "kpop") {
      return playlist.where((s) => s.artist.toLowerCase().contains("bts") || s.artist.toLowerCase().contains("blackpink") || s.title.toLowerCase().contains("k-pop")).toList();
    } else if (normalizedQuery == "pop") {
      return playlist.where((s) => s.artist.toLowerCase().contains("wren") || s.artist.toLowerCase().contains("grey d")).toList();
    } else if (normalizedQuery == "hip-hop" || normalizedQuery == "hip hop") {
      return playlist.where((s) => s.artist.toLowerCase().contains("mck") || s.artist.toLowerCase().contains("tlinh")).toList();
    } else if (normalizedQuery == "dance & electronic" || normalizedQuery == "dance") {
      return playlist.where((s) => s.title.toLowerCase().contains("độc thân") || s.title.toLowerCase().contains("ghệ iu")).toList();
    } else if (normalizedQuery == "moi phat hanh") {
      return playlist.reversed.take(5).toList();
    }
    
    return playlist.where((song) {
      final titleMatch = removeDiacritics(song.title.toLowerCase()).contains(normalizedQuery);
      final artistMatch = removeDiacritics(song.artist.toLowerCase()).contains(normalizedQuery);
      return titleMatch || artistMatch;
    }).toList();
  }

  /// Validate if a URL is likely playable (not a placeholder)
  bool _isValidAudioUrl(String url) {
    if (url.isEmpty) return false;
    if (url.contains('domain.com')) return false;
    if (!url.startsWith('http://') && !url.startsWith('https://')) return false;
    return true;
  }

  Future<void> _safePlay(String url) async {
    if (!_isValidAudioUrl(url)) {
      print("Skipping invalid/placeholder audio URL: $url");
      return;
    }
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      print("AudioPlayers Playback Error: $e");
      // Reset player sau lỗi để tránh cascade crash
      _resetAudioPlayer();
    }
  }

  // Toggle audio playback
  void togglePlay() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      addRecentlyPlayedSong(currentSong);
      _safePlay(currentSong.audioUrl);
    }
    notifyListeners();
  }

  void play() {
    addRecentlyPlayedSong(currentSong);
    _safePlay(currentSong.audioUrl);
    notifyListeners();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  Future<void> addRecentlyPlayedSong(Song song) async {
    if (_currentUid == null) return;

    final item = RecentlyPlayedItem(
      title: song.title,
      subtitle: "${song.artist} • Bài hát",
      imageUrl: song.albumArt,
      type: "song",
      playedAt: DateTime.now(),
      details: song.artist,
      creator: null,
      hasCheck: false,
    );

    _recentlyPlayedList.removeWhere((x) => x.title == item.title && x.type == "song");
    _recentlyPlayedList.insert(0, item);

    if (_recentlyPlayedList.length > 50) {
      _recentlyPlayedList = _recentlyPlayedList.sublist(0, 50);
    }

    // Cập nhật UI NGAY LẬP TỨC trước khi ghi Firestore
    notifyListeners();

    // Ghi Firestore trong background, không block UI
    try {
      await FirebaseFirestore.instance.collection('recently_played').doc(_currentUid!).set({
        'items': _recentlyPlayedList.map((x) => x.toJson()).toList(),
      });
    } catch (e) {
      print("Firestore recently_played save error: $e");
    }
  }

  void next() {
    if (_isShuffled && playlist.length > 1) {
      final random = Random();
      int nextIndex = _currentIndex;
      while (nextIndex == _currentIndex) {
        nextIndex = random.nextInt(playlist.length);
      }
      _currentIndex = nextIndex;
    } else {
      _currentIndex = (_currentIndex + 1) % playlist.length;
    }
    _currentPosition = Duration.zero;
    addRecentlyPlayedSong(playlist[_currentIndex]);
    _safePlay(playlist[_currentIndex].audioUrl);
    notifyListeners();
  }

  void previous() {
    if (_isShuffled && playlist.length > 1) {
      final random = Random();
      int prevIndex = _currentIndex;
      while (prevIndex == _currentIndex) {
        prevIndex = random.nextInt(playlist.length);
      }
      _currentIndex = prevIndex;
    } else {
      _currentIndex = (_currentIndex - 1 + playlist.length) % playlist.length;
    }
    _currentPosition = Duration.zero;
    addRecentlyPlayedSong(playlist[_currentIndex]);
    _safePlay(playlist[_currentIndex].audioUrl);
    notifyListeners();
  }

  void playSong(Song song) {
    final index = playlist.indexOf(song);
    if (index != -1) {
      _currentIndex = index;
      _currentPosition = Duration.zero;
      addRecentlyPlayedSong(song);
      _safePlay(song.audioUrl);
      notifyListeners();
    }
  }

  // Add new song to the global library
  Future<void> addNewSong(Song song) async {
    playlist.add(song);
    notifyListeners();

    try {
      final docId = "song_${DateTime.now().millisecondsSinceEpoch}";
      await FirebaseFirestore.instance.collection('songs').doc(docId).set({
        'title': song.title,
        'artist': song.artist,
        'albumArt': song.albumArt,
        'bannerText': song.bannerText,
        'subtitle': song.subtitle,
        'themeColor': '0x' + song.themeColor.value.toRadixString(16).toUpperCase(),
        'lyrics': song.lyrics,
        'audioUrl': song.audioUrl,
      });
    } catch (e) {
      print("Error seeding/saving new song: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
