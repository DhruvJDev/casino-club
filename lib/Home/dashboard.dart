import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 1200
        ? 32.0
        : width >= 760
            ? 24.0
            : 18.0;
    final cardWidth = width >= 1100
        ? 228.0
        : width >= 760
            ? 188.0
            : 156.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            horizontalPadding, width >= 760 ? 28 : 22, horizontalPadding, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 7),
              child: const Text(
                'GOOD MORNING',
                style: TextStyle(
                  color: Color(0xFF6966F6),
                  fontSize: 11,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Text(
              'Overview',
              style: TextStyle(
                  fontSize: 32,
                  height: 1.12,
                  letterSpacing: -0.8,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            const Text(
              'Casino performance at a glance',
              style:
                  TextStyle(color: Colors.white54, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _MetricCard(
                  width: cardWidth,
                  title: 'Play points',
                  value: '12,480',
                  change: '+8.4%',
                  icon: Icons.sports_esports,
                  color: const Color(0xFF6966F6),
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'View points',
                  value: '38,920',
                  change: '+12.1%',
                  icon: Icons.visibility,
                  color: const Color(0xFF20C997),
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'End points',
                  value: '8,206',
                  change: '+5.7%',
                  icon: Icons.flag,
                  color: const Color(0xFFFFB547),
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'Active games',
                  value: '24',
                  change: '+3',
                  icon: Icons.grid_view,
                  color: const Color(0xFFFF6B81),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _ActivityCard(),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
  });

  final double width;
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 158,
      padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF171A23),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF20C997).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  change,
                  style: const TextStyle(
                    color: Color(0xFF20C997),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(title,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF171A23),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent activity',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          ...const [
            ('Poker room', '24 players', Icons.casino),
            ('Blackjack', '18 players', Icons.style),
            ('Roulette', '12 players', Icons.album),
            ('Slots', '31 players', Icons.confirmation_number),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6966F6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        Icon(item.$3, color: const Color(0xFF6966F6), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$1,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        Text(item.$2,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: Colors.white38, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
