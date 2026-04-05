import 'dart:io';

void main() {
  final dir = Directory('lib');
  final entities = dir.listSync(recursive: true);

  for (var entity in entities) {
    if (entity is File && entity.path.endsWith('.dart') && !entity.path.contains('constants.dart')) {
      String content = entity.readAsStringSync();
      bool changed = false;

      final Map<String, String> replacements = {
        'AppColors.backgroundWhite': 'Theme.of(context).scaffoldBackgroundColor',
        'AppColors.textPrimary': 'Theme.of(context).colorScheme.onSurface',
        'AppColors.textSecondary': 'Theme.of(context).colorScheme.onSurfaceVariant',
        'color: Colors.white': 'color: Theme.of(context).cardColor',
        'color: Colors.grey.shade200': 'color: Theme.of(context).dividerColor.withOpacity(0.1)',
        'Border.all(color: Colors.grey.shade200)': 'Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1))',
        'const TextStyle(color: Theme.of(context)': 'TextStyle(color: Theme.of(context)',
        'const IconThemeData(color: Theme.of(context)': 'IconThemeData(color: Theme.of(context)'
      };

      replacements.forEach((key, value) {
        if (content.contains(key)) {
          content = content.replaceAll(key, value);
          changed = true;
        }
      });

      // Special cases where Theme.of(context) was inside a const widget
      content = content.replaceAll('const Center(\n                      child: Column(\n                        mainAxisAlignment: MainAxisAlignment.center,\n                        children: [\n                          Icon(Icons.history, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),\n                          SizedBox(height: 16),\n                          Text(\n                            \'No orders placed yet\',\n                            style: TextStyle(\n                              fontSize: 18,\n                              color: Theme.of(context).colorScheme.onSurfaceVariant,', 
      'Center(\n                      child: Column(\n                        mainAxisAlignment: MainAxisAlignment.center,\n                        children: [\n                          Icon(Icons.history, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),\n                          const SizedBox(height: 16),\n                          Text(\n                            \'No orders placed yet\',\n                            style: TextStyle(\n                              fontSize: 18,\n                              color: Theme.of(context).colorScheme.onSurfaceVariant,');

      if (changed) {
        // Strip const from parent widgets if they contain Theme.of
        content = content.replaceAllMapped(
          RegExp(r'const\s+([A-Za-z0-9_]+)\([^)]*Theme\.of\(context\)'), 
          (match) => '\${match.group(1)}(' + match.group(0)!.substring(match.group(1)!.length + 7)
        );
        entity.writeAsStringSync(content);
        print('Updated \${entity.path}');
      }
    }
  }
}
