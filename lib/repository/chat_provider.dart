import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:chatbot_app/model/chat_room.dart';
import 'package:chatbot_app/utils/shared_helpers.dart';
import 'package:flutter/foundation.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatRoom> _chats = [];
  final List<String> _names = [
    "Ava",
    "Emma",
    "Olivia",
    "Sophia",
    "Isabella",
    "Mia",
    "Amelia",
    "Harper",
    "Evelyn",
    "Abigail",
    "Emily",
    "Charlotte",
    "Scarlett",
    "Madison",
    "Elizabeth",
    "Grace",
    "Lily",
    "Aria",
    "Ella",
    "Chloe",
    "Victoria",
    "Penelope",
    "Layla",
    "Riley",
    "Zoey",
    "Nora",
    "Hannah",
    "Addison",
    "Stella",
    "Aurora",
    "Savannah",
    "Avery",
    "Sofia",
    "Alexa",
    "Aubrey",
    "Scarlett",
    "Camila",
    "Zoe",
    "Scarlett",
    "Ariana",
    "Ellie",
    "Natalie",
    "Leah",
    "Hazel",
    "Brooklyn",
    "Samantha",
    "Audrey",
    "Claire",
    "Paisley",
    "Skylar",
    "Violet",
    "Brielle",
    "Sarah",
    "Kennedy",
    "Maya",
    "Caroline",
    "Genesis",
    "Aaliyah",
    "Kennedy",
    "Hailey",
    "Gabriella",
    "Lucy",
    "Autumn",
    "Serenity",
    "Sadie",
    "Willow",
    "Arianna",
    "Kaylee",
    "Annabelle",
    "Alexa",
    "Gabriella",
    "Quinn",
    "Madeline",
    "Kayla",
    "Clara",
    "Paisley",
    "Reagan",
    "Delilah",
    "Allison",
    "Bailey",
    "Nevaeh",
    "Makayla",
    "Peyton",
    "Rylee",
    "Alice",
    "Clara",
    "Hadley",
    "Melody",
    "Julia",
    "Cora",
    "Naomi",
    "Ariel",
    "Jasmine",
    "Valentina",
    "Eliana",
    "Brianna",
    "Isabelle",
    "Ruby",
    "Sophie",
    "Alyssa",
    "Gabrielle",
    "Piper",
    "Jocelyn",
    "Julianna",
    "Morgan",
    "London",
    "Gracie",
    "Brooke",
    "Mariah",
    "Kaitlyn",
    "Eden",
    "Eliza",
    "Lola",
    "Gianna",
    "Olive",
    "Aspen",
    "June",
    "Noelle",
    "Anastasia",
    "Angelina",
    "Jayla",
    "Paige",
    "Megan",
    "Harper",
    "Makenzie",
    "Mya",
    "Elise",
    "Kylie",
    "Alana",
    "Reese",
    "Lyla",
    "Ana",
    "Gabriela",
    "Dakota",
    "Catherine",
    "Bianca",
    "Vanessa",
    "Seraphina",
    "Lana",
    "Molly",
    "Clara",
    "Erika",
    "Harmony",
    "Ariel",
    "Angel",
    "Talia",
    "Isla",
    "Julia",
    "Lola",
    "Hope",
    "Tessa",
    "Andrea",
    "Elaina",
    "Juliette",
    "Summer",
    "Daisy",
    "Natasha",
    "Jada",
    "Keira",
    "Alaina",
    "Diana",
    "Jane",
    "Christina",
    "Raegan",
    "Camille",
    "Olive",
    "Esther",
    "Harley",
    "Jennifer",
    "Adeline",
    "Lexi",
    "Emerson",
    "Kaydence",
    "Miranda",
    "Alivia",
    "Elsie",
    "Kiara",
    "Camryn",
    "Megan",
    "Lucia",
    "Danielle",
    "Annie",
    "Heidi",
    "Laura",
    "Brynn",
    "Arabella",
    "Kelsey",
    "Veronica",
    "Haven",
    "Aniyah",
    "Alyssa",
    "Dylan",
    "Jamie",
    "Bethany",
    "Margaret",
    "Regina",
    "Kelly",
    "Jolie",
    "Ariel",
    "Athena",
    "Skyler",
    "Elle",
    "Lucille",
    "Lexie",
    "Carmen",
    "Arya",
    "Paris",
    "Harlow",
    "Leila",
    "Evangeline",
    "Giselle",
    "Fiona",
    "Dayana",
    "Esmeralda",
    "Selena",
    "Jewel",
    "Malia",
    "April",
    "Eden",
    "Amaya",
    "Annalise",
    "Gwendolyn",
    "Evie",
    "Lana",
    "Tatum",
    "Karina",
    "Wren",
    "Raven",
    "Helen",
    "Kayleigh",
    "Carolina",
    "Callie",
    "Juniper",
    "Francesca",
    "Danielle",
    "Alayna",
    "Natasha",
    "Luciana",
    "Presley",
    "Celeste",
    "Mira",
    "Remy",
    "Helena",
    "Maci",
    "Leighton",
    "Jenna",
    "Charlee",
    "Camilla",
    "Mabel",
    "Annie",
    "Mckenna",
    "Sidney",
    "Holland",
    "Peyton",
    "Brenda",
    "Lila",
    "Cataleya",
    "Eileen",
    "Mara",
    "Braelynn",
    "Siena",
    "Helena",
    "Tenley",
    "Clarissa",
    "Kiera",
    "Marilyn",
    "Paloma",
    "Cassidy",
    "Shayla",
    "Kaia",
    "Phoebe",
    "Journey",
    "Aisha",
    "Kali",
    "Camila",
    "Aileen",
    "Elaine",
    "Kassidy",
    "Marlee",
    "Leona",
    "Ryan",
    "Jessie",
    "Marilyn",
    "Priscilla",
    "Halle",
    "Kylie",
    "Lilith",
    "Jamie",
    "Kailani",
    "Nia",
    "Briar",
    "Lorelei",
    "Rylan",
    "Maeve",
    "Brinley",
    "Arielle",
    "Fernanda",
    "Christine",
    "Alma",
    "Elora",
    "Anne",
    "Nylah",
    "Belle",
    "Ember",
    "Raven",
    "Aviana",
    "Irene",
    "Anahi",
    "Jayleen",
    "Mariana",
    "Kiana",
    "Arabella",
    "Emmalyn",
    "Elaine",
    "Celestia",
    "Zara",
    "Liliana",
    "Alanna",
    "Daphne",
    "Astrid",
    "Joelle",
    "Tiffany",
    "Gloria",
    "Cataleya",
    "Octavia",
    "Annika",
    "Della",
    "Mae",
    "Kassandra",
    "Sylvie",
    "Dayana",
    "Maxine",
    "Lara"
  ];

  List<ChatRoom> get chats => _chats;
  bool get isNotEmpty => _chats.isNotEmpty;
  bool get isEmpty => _chats.isEmpty;

  String getName() {
    String? newName;

    do {
      String generateName = _names[Random().nextInt(_names.length)];

      if (!_chats.any((e) =>
          e.name?.replaceAll(" ", "") == generateName.replaceAll(" ", ""))) {
        newName = generateName;
      }
    } while (newName == null);

    return newName;
  }

  Future<void> addChat(ChatRoom chats) async {
    _chats.add(chats);
    await saveChatsToString();
    notifyListeners();
  }

  Future<void> pinChat(ChatRoom chats) async {
    int index = _chats.indexWhere((e) => e.id == chats.id);

    if (index != -1) {
      _chats[index].pinned = !(_chats[index].pinned ?? false);
      await saveChatsToString();
      notifyListeners();
    }
  }

  Future<void> updateChat(ChatRoom chats) async {
    int index = _chats.indexWhere((e) => e.id == chats.id);

    if (index != -1) {
      _chats[index] = chats;
      await saveChatsToString();
      notifyListeners();
    }
  }

  Future<void> deleteChat(String chatsId) async {
    _chats.removeWhere((e) => e.id == chatsId);
    await saveChatsToString();
    notifyListeners();
  }

  Future<void> saveChatsToString() async {
    final encodedList = jsonEncode(_chats);
    await setSharedString('ChatProvider', encodedList);
  }

  Future<void> loadChatsFromString() async {
    final encodedList = await getSharedString('ChatProvider');

    if (encodedList != null && encodedList.isNotEmpty) {
      _chats.clear();
      _chats.addAll(ChatRoom.fromJsonToList(jsonDecode(encodedList)));
    }

    await saveChatsToString();
    notifyListeners();
  }
}
