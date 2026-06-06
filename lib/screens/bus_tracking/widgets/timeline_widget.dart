import 'package:flutter/material.dart';
import '../models/tracking_model.dart';

class RouteTimelineWidget extends StatelessWidget {
  final List<RouteStopStatus> stops;

  const RouteTimelineWidget({super.key, required this.stops});

  @override
  Widget build(BuildContext context) {
    if (stops.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No route stops defined.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(stops.length, (index) {
        final stop = stops[index];
        final isLast = index == stops.length - 1;

        Color indicatorColor;
        IconData? icon;
        double indicatorSize = 24.0;
        
        // Define colors based on stop status
        if (stop.status == 'reached') {
          indicatorColor = const Color(0xFF10B981); // Emerald Green
          icon = Icons.check;
        } else if (stop.status == 'current') {
          indicatorColor = const Color(0xFF174EA6); // Deep Blue
          icon = Icons.directions_bus;
          indicatorSize = 30.0;
        } else {
          indicatorColor = const Color(0xFF98A2B3); // Slate Grey
          icon = null;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: Dot and vertical line
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: indicatorSize,
                    height: indicatorSize,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      shape: BoxShape.circle,
                      boxShadow: stop.status == 'current'
                          ? [
                              BoxShadow(
                                color: indicatorColor.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: icon != null
                        ? Icon(
                            icon,
                            color: Colors.white,
                            size: indicatorSize * 0.6,
                          )
                        : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 3,
                        color: stop.status == 'reached'
                            ? const Color(0xFF10B981)
                            : const Color(0xFFE4E7EC),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Right: Stop information
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            stop.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: stop.status == 'current'
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: stop.status == 'upcoming'
                                  ? const Color(0xFF667085)
                                  : const Color(0xFF101828),
                            ),
                          ),
                          if (stop.arrivalTime != null)
                            Text(
                              stop.arrivalTime!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            )
                          else if (stop.status == 'current')
                            const Text(
                              'Current Stop',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF174EA6),
                              ),
                            )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stop.status == 'reached'
                            ? 'Reached'
                            : stop.status == 'current'
                                ? 'Arriving Now'
                                : 'Upcoming',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: stop.status == 'reached'
                              ? const Color(0xFF10B981)
                              : stop.status == 'current'
                                  ? const Color(0xFF174EA6)
                                  : const Color(0xFF98A2B3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
