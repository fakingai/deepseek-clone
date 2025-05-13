import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/conversation/conversation_bloc.dart';
import '../bloc/conversation/conversation_state.dart';
import '../bloc/conversation/conversation_event.dart';
import '../../domain/entities/conversation.dart';
import 'conversation_item.dart';

class ConversationList extends StatelessWidget {
  const ConversationList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        print("ConversationList state: $state");
        if (state is ConversationLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ConversationLoaded) {
          final sessions = state.sessions;
          print("ConversationList sessions: ${sessions.length}");
          
          if (sessions.isEmpty) {
            return const Center(
              child: Text('No chat sessions yet'),
            );
          }
          
          // Group sessions by date
          final Map<String, List<Conversation>> groupedSessions = {};
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final yesterday = today.subtract(const Duration(days: 1));
          final sevenDaysAgo = today.subtract(const Duration(days: 7));
          final thirtyDaysAgo = today.subtract(const Duration(days: 30));

          List<Conversation> todaySessions = [];
          List<Conversation> yesterdaySessions = [];
          List<Conversation> within7DaysSessions = [];
          List<Conversation> within30DaysSessions = [];
          Map<String, List<Conversation>> olderSessionsByMonth = {};

          for (var session in sessions) {
            final sessionDate = DateTime(session.updatedAt.year, session.updatedAt.month, session.updatedAt.day);
            if (sessionDate.isAtSameMomentAs(today)) {
              todaySessions.add(session);
            } else if (sessionDate.isAtSameMomentAs(yesterday)) {
              yesterdaySessions.add(session);
            } else if (sessionDate.isAfter(sevenDaysAgo)) {
              within7DaysSessions.add(session);
            } else if (sessionDate.isAfter(thirtyDaysAgo)) {
              within30DaysSessions.add(session);
            } else {
              final monthYear = '${session.updatedAt.year}年${session.updatedAt.month}月';
              olderSessionsByMonth.putIfAbsent(monthYear, () => []).add(session);
            }
          }

          // Sort sessions within each group by most recent first
          todaySessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          yesterdaySessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          within7DaysSessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          within30DaysSessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          olderSessionsByMonth.forEach((key, value) {
            value.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          });

          if (todaySessions.isNotEmpty) {
            groupedSessions['今天'] = todaySessions;
          }
          if (yesterdaySessions.isNotEmpty) {
            groupedSessions['昨天'] = yesterdaySessions;
          }
          if (within7DaysSessions.isNotEmpty) {
            groupedSessions['近7天内'] = within7DaysSessions;
          }
          if (within30DaysSessions.isNotEmpty) {
            groupedSessions['近30天内'] = within30DaysSessions;
          }
          olderSessionsByMonth.forEach((key, value) {
            if (value.isNotEmpty) {
              groupedSessions[key] = value;
            }
          });
          
          // Define the desired order of categories
          final categoryOrder = ['今天', '昨天', '近7天内', '近30天内'];
          
          // Get sorted keys based on the defined order and then by date for older items
          List<String> sortedKeys = groupedSessions.keys.toList();
          sortedKeys.sort((a, b) {
            int indexA = categoryOrder.indexOf(a);
            int indexB = categoryOrder.indexOf(b);

            if (indexA != -1 && indexB != -1) {
              return indexA.compareTo(indexB); // Both are in predefined order
            } else if (indexA != -1) {
              return -1; // A is predefined, B is not (should come after)
            } else if (indexB != -1) {
              return 1; // B is predefined, A is not (should come after)
            } else {
              // Both are older dates (e.g., "2023年10月"), sort them chronologically descending
              // This requires parsing the year and month
              try {
                final partsA = a.replaceAll('年', '-').replaceAll('月', '').split('-');
                final dateA = DateTime(int.parse(partsA[0]), int.parse(partsA[1]));
                final partsB = b.replaceAll('年', '-').replaceAll('月', '').split('-');
                final dateB = DateTime(int.parse(partsB[0]), int.parse(partsB[1]));
                return dateB.compareTo(dateA); // Sort by most recent month first
              } catch (e) {
                return a.compareTo(b); // Fallback to string comparison
              }
            }
          });

          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView.builder(
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
              final category = sortedKeys[index];
              final categoryItems = groupedSessions[category]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ...categoryItems.map((session) => ConversationItem(
                    session: session,
                    isSelected: state.selectedSessionId == session.id,
                    onTap: () {
                      context.read<ConversationBloc>().add(
                        SelectConversationEvent(id: session.id),
                      );
                      
                      Future.microtask(() {
                        if (Scaffold.of(context).hasDrawer && 
                            Scaffold.of(context).isDrawerOpen) {
                          Navigator.pop(context);
                        }
                      });
                    },
                  )).toList()
                ],
              );
            },
          ));
        } else if (state is ConversationError) {
          return Center(
            child: Text(state.message),
          );
        }
        
        return const Center(
          child: Text('No sessions found'), // Should be covered by ConversationLoaded empty state
        );
      },
    );
  }
}
