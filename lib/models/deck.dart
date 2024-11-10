class FlashCard {
  String id;
  String question;
  String answer;

  FlashCard({required this.id, required this.question, required this.answer});

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
  };

  factory FlashCard.fromJson(Map<String, dynamic> json) => FlashCard(
    id: json['id'],
    question: json['question'],
    answer: json['answer'],
  );
}

class Deck {
  String id;
  String name;
  List<FlashCard> cards;

  Deck({required this.id, required this.name, required this.cards});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cards': cards.map((card) => card.toJson()).toList(),
  };

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
    id: json['id'],
    name: json['name'],
    cards: (json['cards'] as List).map((card) => FlashCard.fromJson(card)).toList(),
  );
}