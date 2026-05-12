import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/onboarding_provider.dart';

const _backgroundColor = Color(0xFFEAF6FF);
const _primaryColor = Color(0xFF067DF7);
const _textColor = Color(0xFF14243D);
const _mutedTextColor = Color(0xFF6F8197);
const _cardColor = Color(0xFFDCEEFF);
const _borderColor = Color(0xFFC4D8EA);

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    ref.read(onboardingControllerProvider.notifier).setPage(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: PageView(
              controller: _pageController,
              onPageChanged:
                  ref.read(onboardingControllerProvider.notifier).setPage,
              children: [
                IntroOnboardingPage(onNext: () => _goToPage(1)),
                const InterestOnboardingPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IntroOnboardingPage extends ConsumerWidget {
  const IntroOnboardingPage({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIndex = ref.watch(
      onboardingControllerProvider.select((state) => state.pageIndex),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StatusBar(),
          const SizedBox(height: 26),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: _cardColor),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  color: Color(0xFF91C7F5),
                  size: 34,
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
          _PageDots(activeIndex: pageIndex),
          const SizedBox(height: 22),
          Text(
            'Create a prototype in just\na few minutes',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _textColor,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Enjoy these pre-made components and worry only\nabout creating the best product ever.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _mutedTextColor,
              height: 1.45,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 28),
          _PrimaryButton(label: 'Next', onPressed: onNext),
        ],
      ),
    );
  }
}

class InterestOnboardingPage extends ConsumerWidget {
  const InterestOnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interests = ref.watch(onboardingInterestsProvider);
    final selectedInterestIds = ref.watch(
      onboardingControllerProvider.select((state) => state.selectedInterestIds),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StatusBar(),
          const SizedBox(height: 38),
          const _ProgressIndicatorBar(value: 0.5),
          const SizedBox(height: 42),
          Text(
            'Personalise your\nexperience',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _textColor,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Choose your interests.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _mutedTextColor,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final interest = interests[index];
                return _InterestTile(
                  label: interest.name,
                  selected: selectedInterestIds.contains(interest.id),
                  onTap:
                      () => ref
                          .read(onboardingControllerProvider.notifier)
                          .toggleInterest(interest.id),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: interests.length,
            ),
          ),
          const SizedBox(height: 14),
          _PrimaryButton(label: 'Next', onPressed: () {}),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '9:41',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: _textColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const Spacer(),
        const Icon(Icons.signal_cellular_4_bar, size: 15, color: _textColor),
        const SizedBox(width: 4),
        const Icon(Icons.wifi, size: 15, color: _textColor),
        const SizedBox(width: 4),
        const Icon(Icons.battery_full, size: 17, color: _textColor),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(2, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(right: 8),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? _primaryColor : const Color(0xFFBFD5E7),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _ProgressIndicatorBar extends StatelessWidget {
  const _ProgressIndicatorBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 7,
        child: LinearProgressIndicator(
          value: value,
          color: _primaryColor,
          backgroundColor: const Color(0xFFD0E2F2),
        ),
      ),
    );
  }
}

class _InterestTile extends StatelessWidget {
  const _InterestTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _cardColor : _backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _textColor,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: _primaryColor,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
