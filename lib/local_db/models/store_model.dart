class FollowerModel {
  final String followerId;
  final String followerImageUrl;

  FollowerModel({
    required this.followerId,
    required this.followerImageUrl,
  });

  // Convert the model to a map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'followerId': followerId,
      'followerImageUrl': followerImageUrl,
    };
  }

  // Create a model from a map retrieved from the database
  factory FollowerModel.fromMap(Map<String, dynamic> map) {
    return FollowerModel(
      followerId: map['followerId'],
      followerImageUrl: map['followerImageUrl'],
    );
  }
}
