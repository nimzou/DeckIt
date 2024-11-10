import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../widgets/add_card_dialog.dart';
import '../widgets/edit_card_dialog.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../services/storage_service.dart';

class DeckDetailScreen extends StatefulWidget {
  final Deck deck;
  final StorageService storage;
  final List<Deck> decks;

  const DeckDetailScreen({
    required this.deck,
    required this.storage,
    required this.decks,
    super.key,
  });

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  Future<void> _addCard() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddCardDialog(),
    );
    if (result != null) {
      setState(() {
        widget.deck.cards.add(FlashCard(
          id: DateTime.now().toString(),
          question: result['question']!,
          answer: result['answer']!,
        ));
      });
      await widget.storage.saveDecks(widget.decks);
    }
  }

  Future<void> _editCard(int index) async {
    final card = widget.deck.cards[index];
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => EditCardDialog(
        initialQuestion: card.question,
        initialAnswer: card.answer,
      ),
    );
    if (result != null) {
      setState(() {
        widget.deck.cards[index] = FlashCard(
          id: card.id,
          question: result['question']!,
          answer: result['answer']!,
        );
      });
      await widget.storage.saveDecks(widget.decks);
    }
  }

  Future<void> _deleteCard(int index) async {
    final card = widget.deck.cards[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        itemName: card.question,
      ),
    );

    if (confirmed == true) {
      setState(() {
        widget.deck.cards.removeAt(index);
      });
      await widget.storage.saveDecks(widget.decks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.library_books,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.deck.name,
                overflow: TextOverflow.ellipsis, // Truncate with ellipsis
                style: Theme.of(context).textTheme.titleLarge, // Use titleLarge for the text style
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.deck.cards.length} cards',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap a card to see details',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _addCard,
                  icon: const Icon(
                    Icons.add_circle,
                    size: 28,
                  ),
                  label: const Text(
                    'Add Card',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.deck.cards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No cards yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first flashcard to get started',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color:
                                    Theme.of(context).textTheme.bodySmall?.color,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: widget.deck.cards.length,
                    itemBuilder: (context, index) {
                      final card = widget.deck.cards[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        elevation: 1,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            title: Text(
                              card.question,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                ),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Answer:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      card.answer,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => _editCard(index),
                                          icon: const Icon(Icons.edit, size: 20),
                                          label: const Text('Edit'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          onPressed: () => _deleteCard(index),
                                          icon:
                                              const Icon(Icons.delete, size: 20),
                                          label: const Text('Delete'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}