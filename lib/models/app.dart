class App {
  String name;
  String description;
  String repo;
  String url;
  String get githubUrl => 'https://github.com/$repo';
  String get githubBadgeStars =>
      'https://img.shields.io/github/stars/${repo}?style=social';

  String get md {
    String linkedName = '[${name}](${url ?? githubUrl})';
    String linkedBadgeStars =
        '[![GitHub Repo stars]($githubBadgeStars)]($githubUrl)';
    return '| $linkedName | $linkedBadgeStars | ${description} |';
  }

  App({
    this.name,
    this.description,
    this.repo,
    this.url,
  });

  factory App.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return App(
      name: json['name'],
      description: json['description'],
      repo: json['repo'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'repo': repo,
      'url': url,
    };
  }
}
