import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../services/storage_service.dart';

class ReviewTab extends StatefulWidget {
  final StorageService storage;
  const ReviewTab({required this.storage, super.key});

  @override
  State<ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> {
  List<Deck> decks = [];
  List<FlashCard> currentCards = [];
  int currentCardIndex = 0;
  bool showingAnswer = false;
  bool isReviewing = false;
  Deck? selectedDeck;

  @override
  void initState() {
    super.initState();
    _loadDecks();
    _setupPeriodicUpdates();
  }

  void _setupPeriodicUpdates() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _refreshCurrentDeck();
        _setupPeriodicUpdates();
      }
    });
  }

  Future<void> _refreshCurrentDeck() async {
    if (selectedDeck != null) {
      final updatedDecks = await widget.storage.getDecks();
      final updatedDeck = updatedDecks.firstWhere(
        (deck) => deck.id == selectedDeck!.id,
        orElse: () => selectedDeck!,
      );

      if (mounted) {
        setState(() {
          decks = updatedDecks;
          selectedDeck = updatedDeck;
          currentCards = updatedDeck.cards;
          if (currentCardIndex >= currentCards.length) {
            currentCardIndex = currentCards.isEmpty ? 0 : currentCards.length - 1;
          }
        });
      }
    } else {
      _loadDecks();
    }
  }

  Future<void> _loadDecks() async {
    final loadedDecks = await widget.storage.getDecks();
    if (mounted) {
      setState(() {
        decks = loadedDecks;
      });
    }
  }

  void _startReview(Deck deck) {
    setState(() {
      selectedDeck = deck;
      currentCards = deck.cards;
      currentCardIndex = 0;
      showingAnswer = false;
      isReviewing = true;
    });
  }

  void _endReview() {
    setState(() {
      isReviewing = false;
      selectedDeck = null;
      currentCards = [];
      currentCardIndex = 0;
      showingAnswer = false;
    });
  }

  void _nextCard() {
    setState(() {
      if (currentCardIndex < currentCards.length - 1) {
        currentCardIndex++;
        showingAnswer = false;
      }
    });
  }

  void _previousCard() {
    setState(() {
      if (currentCardIndex > 0) {
        currentCardIndex--;
        showingAnswer = false;
      }
    });
  }

  void _toggleCard() {
    setState(() {
      showingAnswer = !showingAnswer;
    });
  }

  Widget _buildDeckList() {
    if (decks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_disabled_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Decks Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first card to start reviewing!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: decks.length,
        itemBuilder: (context, index) {
          final deck = decks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                deck.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('${deck.cards.length} cards'),
              trailing: IconButton(
                icon: const Icon(Icons.play_circle_filled),
                color: Theme.of(context).colorScheme.primary,
                iconSize: 32,
                onPressed: deck.cards.isEmpty
                    ? null
                    : () => _startReview(deck),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewScreen() {
    if (currentCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No cards in this deck'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _endReview,
              child: const Text('Back to Deck List'),
            ),
          ],
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final currentCard = currentCards[currentCardIndex];
    final hasAnswer = currentCard.answer.trim().isNotEmpty;

    return SafeArea(
      child: Column(
        children: [
          // Progress indicator and counter
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  '${currentCardIndex + 1} / ${currentCards.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                ),
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (currentCardIndex + 1) / currentCards.length,
                      minHeight: 8,
                      backgroundColor: colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Flashcard
          Expanded(
            child: GestureDetector(
              onTap: _toggleCard,
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Centered content container
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 32), // Space for icon
                                      SelectableText(
                                        showingAnswer
                                            ? (hasAnswer ? currentCard.answer : 'No answer provided')
                                            : currentCard.question,
                                        style: Theme.of(context).textTheme.headlineSmall,
                                        textAlign: TextAlign.center,
                                      ),
                                      if (showingAnswer && !hasAnswer) ...[
                                        const SizedBox(height: 16),
                                        Icon(
                                          Icons.warning_rounded,
                                          size: 48,
                                          color: colorScheme.error.withOpacity(0.6),
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Visibility indicator
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceDim.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          showingAnswer
                              ? (hasAnswer ? Icons.visibility : Icons.warning_rounded)
                              : Icons.visibility_off,
                          color: showingAnswer && !hasAnswer
                              ? colorScheme.error
                              : colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: currentCardIndex > 0
                        ? colorScheme.primaryContainer.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: currentCardIndex > 0 ? _previousCard : null,
                    color: currentCardIndex > 0
                        ? colorScheme.primary
                        : Colors.grey,
                    iconSize: 28,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      showingAnswer ? Icons.visibility : Icons.visibility_off,
                      color: colorScheme.primary,
                    ),
                    onPressed: _toggleCard,
                    iconSize: 28,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: currentCardIndex < currentCards.length - 1
                        ? colorScheme.primaryContainer.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: currentCardIndex < currentCards.length - 1
                        ? _nextCard
                        : null,
                    color: currentCardIndex < currentCards.length - 1
                        ? colorScheme.primary
                        : Colors.grey,
                    iconSize: 28,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: isReviewing
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _endReview,
              )
            : null,
        title: isReviewing 
            ? Text(
                selectedDeck?.name ?? '',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : Row(
                children: [
                  Icon(
                    Icons.visibility,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Review',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
        automaticallyImplyLeading: !isReviewing,
      ),
      body: isReviewing ? _buildReviewScreen() : _buildDeckList(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}