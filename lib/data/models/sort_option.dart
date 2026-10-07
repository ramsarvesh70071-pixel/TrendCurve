/// Sorting options for trends list.
enum TrendSortOption {
  recentlyUpdated('Recently Updated'),
  nameAsc('Name (A-Z)'),
  highestGrowth('Highest Growth'),
  lowestGrowth('Lowest Growth'),
  highestValue('Highest Value'),
  lowestValue('Lowest Value');

  final String label;
  const TrendSortOption(this.label);
}
