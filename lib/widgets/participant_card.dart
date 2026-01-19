import 'package:flutter/material.dart';
import 'package:mobile/models/participant_model.dart';
import 'package:mobile/screens/participant/participant_screen.dart';
import 'package:mobile/theme/app_theme.dart';
import 'package:mobile/widgets/user_avatar.dart';

class ParticipantCard extends StatelessWidget {
  final Participant participant;

  const ParticipantCard({
    super.key,
    required this.participant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.mainDeepBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ParticipantDetailScreen(participant: participant),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Avatar
                /*CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: participant.photoUrl.isNotEmpty
                      ? NetworkImage(participant.photoUrl)
                      : null,
                  child: participant.photoUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),*/

                UserAvatar(imageUrl: participant.photoUrl, fullName: participant.fullName, radius: 30, ),

                const SizedBox(width: 16),
                
                /// Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Full name
                      Text(
                        participant.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// Profile label
                      Text(
                        participant.profileLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// Country
                      Text(
                        participant.country.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 6),

                      /// Dynamic fields
                      ...participant.feilds
                          .where((f) =>
                              f.showOnParticipantListPage == true &&
                              ((f.value != null && f.value!.isNotEmpty) ||
                                  f.multipleValuesSelected.isNotEmpty))
                          .map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                f.value ??
                                    f.multipleValuesSelected.join(', '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                /// Arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
