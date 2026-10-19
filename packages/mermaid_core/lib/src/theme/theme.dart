/// Mermaid theme variables (subset relevant to currently supported diagrams),
/// with defaults matching upstream theme-default.js.
library;

import '../color.dart';

/// xychart `plotColorPalette` for the default/forest/neutral themes
/// (upstream theme-default.js `#ECECFF,#8493A6,…`).
const _defaultXyChartPlotColorPalette = <Color>[
  Color(0xffececff),
  Color(0xff8493a6),
  Color(0xffffc3a0),
  Color(0xffdcdde1),
  Color(0xffb8e994),
  Color(0xffd1a36f),
  Color(0xffc3cde6),
  Color(0xffffb6c1),
  Color(0xff496078),
  Color(0xfff8f3e3),
];

/// xychart `plotColorPalette` for the dark theme (upstream theme-dark.js).
const _darkXyChartPlotColorPalette = <Color>[
  Color(0xff3498db),
  Color(0xff2ecc71),
  Color(0xffe74c3c),
  Color(0xfff1c40f),
  Color(0xffbdc3c7),
  Color(0xffffffff),
  Color(0xff34495e),
  Color(0xff9b59b6),
  Color(0xff1abc9c),
  Color(0xffe67e22),
];

const _forestXyChartPlotColorPalette = <Color>[
  Color(0xffcde498),
  Color(0xffff6b6b),
  Color(0xffa0d2db),
  Color(0xffd7bde2),
  Color(0xfff0f0f0),
  Color(0xffffc3a0),
  Color(0xff7fd8be),
  Color(0xffff9a8b),
  Color(0xfffaf3e0),
  Color(0xfffff176),
];

/// Caches [MermaidTheme.hashCode] per instance.
///
/// The class has a const constructor, so the cache cannot be a `late final`
/// field. Themes are deeply immutable, so an instance's hash never changes.
final Expando<int> _themeHashCodes = Expando<int>('MermaidTheme.hashCode');

bool _sameValues(List<Object> a, List<Object> b) {
  // Not `identical`-guarded: `_equalityValues` builds a fresh list per call,
  // so the two lists are never the same object.
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class MermaidTheme {
  const MermaidTheme({
    required this.background,
    required this.primaryColor,
    required this.primaryTextColor,
    required this.primaryBorderColor,
    required this.secondaryColor,
    required this.lineColor,
    required this.arrowheadColor,
    required this.textColor,
    required this.nodeBorder,
    required this.mainBkg,
    required this.clusterBkg,
    required this.clusterBorder,
    required this.titleColor,
    required this.edgeLabelBackground,
    required this.fontFamily,
    required this.fontSize,
    this.cScale0 = const Color(0xff8686ff),
    this.cScale1 = const Color(0xffffff78),
    this.cScale2 = const Color(0xffd7ff86),
    this.cScale3 = const Color(0xffc286ff),
    this.cScale4 = const Color(0xffff86ff),
    this.cScale5 = const Color(0xffff86c2),
    this.cScale6 = const Color(0xffff8686),
    this.cScale7 = const Color(0xffffc286),
    this.cScale8 = const Color(0xffc2ff86),
    this.cScale9 = const Color(0xff86ffc2),
    this.cScale10 = const Color(0xff86ffff),
    this.cScale11 = const Color(0xff86c2ff),
    this.cScaleInv0 = const Color(0xffffffb9),
    this.cScaleInv1 = const Color(0xffababff),
    this.cScaleInv2 = const Color(0xffd0b9ff),
    this.cScaleInv3 = const Color(0xffdcffb9),
    this.cScaleInv4 = const Color(0xffb9ffb9),
    this.cScaleInv5 = const Color(0xffb9ffdc),
    this.cScaleInv6 = const Color(0xffb9ffff),
    this.cScaleInv7 = const Color(0xffb9dcff),
    this.cScaleInv8 = const Color(0xffdcb9ff),
    this.cScaleInv9 = const Color(0xffffb9dc),
    this.cScaleInv10 = const Color(0xffffb9b9),
    this.cScaleInv11 = const Color(0xffffdcb9),
    this.cScaleLabel0 = const Color(0xffffffff),
    this.cScaleLabel1 = const Color(0xff000000),
    this.cScaleLabel2 = const Color(0xff000000),
    this.cScaleLabel3 = const Color(0xffffffff),
    this.cScaleLabel4 = const Color(0xff000000),
    this.cScaleLabel5 = const Color(0xff000000),
    this.cScaleLabel6 = const Color(0xff000000),
    this.cScaleLabel7 = const Color(0xff000000),
    this.cScaleLabel8 = const Color(0xff000000),
    this.cScaleLabel9 = const Color(0xff000000),
    this.cScaleLabel10 = const Color(0xff000000),
    this.cScaleLabel11 = const Color(0xff000000),
    this.cScalePeer0 = const Color(0xff3939ff),
    this.cScalePeer1 = const Color(0xfff7f700),
    this.cScalePeer2 = const Color(0xffb5ff20),
    this.cScalePeer3 = const Color(0xff9c39ff),
    this.cScalePeer4 = const Color(0xffff39ff),
    this.cScalePeer5 = const Color(0xffff399c),
    this.cScalePeer6 = const Color(0xffff3939),
    this.cScalePeer7 = const Color(0xffff9c39),
    this.cScalePeer8 = const Color(0xff9cff39),
    this.cScalePeer9 = const Color(0xff39ff9c),
    this.cScalePeer10 = const Color(0xff39ffff),
    this.cScalePeer11 = const Color(0xff399cff),
    this.pie1 = const Color(0xffececff),
    this.pie2 = const Color(0xffffffde),
    this.pie3 = const Color(0xffb9ff20),
    this.pie4 = const Color(0xffb9b9ff),
    this.pie5 = const Color(0xffffff45),
    this.pie6 = const Color(0xffd9ff86),
    this.pie7 = const Color(0xffff86ff),
    this.pie8 = const Color(0xff20ffff),
    this.pie9 = const Color(0xffff2020),
    this.pie10 = const Color(0xffff20ff),
    this.pie11 = const Color(0xff20ff90),
    this.pie12 = const Color(0xffff5353),
    this.pieStrokeColor = const Color(0xff000000),
    this.pieOuterStrokeColor = const Color(0xff000000),
    this.pieSectionTextColor = const Color(0xff333333),
    this.pieLegendTextColor = const Color(0xff000000),
    this.pieTitleTextColor = const Color(0xff000000),
    this.git0 = const Color(0xff6c6cff),
    this.git1 = const Color(0xffffff5e),
    this.git2 = const Color(0xffceff6c),
    this.git3 = const Color(0xff6cb6ff),
    this.git4 = const Color(0xff6cffff),
    this.git5 = const Color(0xff6cffb6),
    this.git6 = const Color(0xffff6cff),
    this.git7 = const Color(0xffff6c6c),
    this.gitInv0 = const Color(0xff131300),
    this.gitInv1 = const Color(0xff0000a1),
    this.gitInv2 = const Color(0xff310093),
    this.gitInv3 = const Color(0xff934900),
    this.gitInv4 = const Color(0xff930000),
    this.gitInv5 = const Color(0xff930049),
    this.gitInv6 = const Color(0xff009300),
    this.gitInv7 = const Color(0xff009393),
    this.gitBranchLabel0 = const Color(0xffffffff),
    this.gitBranchLabel1 = const Color(0xff000000),
    this.gitBranchLabel2 = const Color(0xff000000),
    this.gitBranchLabel3 = const Color(0xffffffff),
    this.gitBranchLabel4 = const Color(0xff000000),
    this.gitBranchLabel5 = const Color(0xff000000),
    this.gitBranchLabel6 = const Color(0xff000000),
    this.gitBranchLabel7 = const Color(0xff000000),
    this.commitLabelColor = const Color(0xff000021),
    this.commitLabelBackground = const Color(0xffffffde),
    this.tagLabelColor = const Color(0xff131300),
    this.tagLabelBackground = const Color(0xffececff),
    this.tagLabelBorder = const Color(0xffc7c7f1),
    this.actorBkg = const Color(0xffececff),
    this.actorBorder = const Color(0xff9370db),
    this.actorTextColor = const Color(0xff000000),
    this.actorLineColor = const Color(0xff9370db),
    this.signalColor = const Color(0xff333333),
    this.signalTextColor = const Color(0xff333333),
    this.labelBoxBkgColor = const Color(0xffececff),
    this.labelBoxBorderColor = const Color(0xff9370db),
    this.labelTextColor = const Color(0xff000000),
    this.loopTextColor = const Color(0xff000000),
    this.noteBkgColor = const Color(0xfffff5ad),
    this.noteBorderColor = const Color(0xffaaaa33),
    this.noteTextColor = const Color(0xff000000),
    this.activationBkgColor = const Color(0xfff4f4f4),
    this.activationBorderColor = const Color(0xff666666),
    this.fillType0 = const Color(0xffececff),
    this.fillType1 = const Color(0xffffffde),
    this.fillType2 = const Color(0xffffecfe),
    this.fillType3 = const Color(0xffdeffe0),
    this.fillType4 = const Color(0xffecfffe),
    this.fillType5 = const Color(0xffffdee0),
    this.fillType6 = const Color(0xffffefec),
    this.fillType7 = const Color(0xffdefbff),
    this.quadrant1Fill = const Color(0xffececff),
    this.quadrant2Fill = const Color(0xfff1f1ff),
    this.quadrant3Fill = const Color(0xfff6f6ff),
    this.quadrant4Fill = const Color(0xfffbfbff),
    this.quadrant1TextFill = const Color(0xff131300),
    this.quadrant2TextFill = const Color(0xff0e0e00),
    this.quadrant3TextFill = const Color(0xff090900),
    this.quadrant4TextFill = const Color(0xff040400),
    this.quadrantPointFill = const Color(0xffb9b9ff),
    this.quadrantPointTextFill = const Color(0xff131300),
    this.quadrantXAxisTextFill = const Color(0xff131300),
    this.quadrantYAxisTextFill = const Color(0xff131300),
    this.quadrantInternalBorderStrokeFill = const Color(0xffc7c7f1),
    this.quadrantExternalBorderStrokeFill = const Color(0xffc7c7f1),
    this.quadrantTitleFill = const Color(0xff131300),
    this.attributeBackgroundColorOdd = const Color(0xffffffff),
    this.attributeBackgroundColorEven = const Color(0xfff2f2f2),
    this.rowOdd = const Color(0xffffffff),
    this.rowEven = const Color(0xfff1f1ff),
    this.venn1 = const Color(0xff5353ff),
    this.venn2 = const Color(0xffffff45),
    this.venn3 = const Color(0xffb9ff20),
    this.venn4 = const Color(0xffff53ff),
    this.venn5 = const Color(0xff53ffff),
    this.venn6 = const Color(0xff45ff45),
    this.venn7 = const Color(0xffff5353),
    this.venn8 = const Color(0xff45ffff),
    this.vennTitleTextColor = const Color(0xff333333),
    this.vennSetTextColor = const Color(0xff333333),
    this.requirementBackground = const Color(0xffececff),
    this.requirementBorderColor = const Color(0xffc7c7f1),
    this.requirementTextColor = const Color(0xff131300),
    this.relationColor = const Color(0xff333333),
    this.relationLabelBackground = const Color(0xcce8e8e8),
    this.relationLabelColor = const Color(0xff000000),
    this.xyChartPlotColorPalette = _defaultXyChartPlotColorPalette,
    this.canvasColor = const Color(0xffffffff),
    this.textOnDarkFill = const Color(0xffffffff),
    this.textOnLightFill = const Color(0xff333333),
    this.tertiaryColor = const Color(0xfff9ffec),
    this.ganttTaskBkgColor = const Color(0xff8a90dd),
    this.ganttTaskBorderColor = const Color(0xff534fbc),
    this.ganttActiveTaskBkgColor = const Color(0xffbfc7ff),
    this.ganttActiveTaskBorderColor = const Color(0xff534fbc),
    this.ganttDoneTaskBkgColor = const Color(0xffd3d3d3),
    this.ganttDoneTaskBorderColor = const Color(0xff808080),
    this.ganttCritBkgColor = const Color(0xffff0000),
    this.ganttCritBorderColor = const Color(0xffff8888),
    this.ganttTaskTextColor = const Color(0xffffffff),
    this.ganttActiveTaskTextColor = const Color(0xff000000),
    this.ganttDoneTaskTextColor = const Color(0xff000000),
    this.ganttCritTaskTextColor = const Color(0xff000000),
    this.ganttTaskTextOutsideColor = const Color(0xff000000),
    this.ganttExcludeBkgColor = const Color(0xffeeeeee),
    this.ganttGridColor = const Color(0xccd3d3d3),
    this.ganttTodayLineColor = const Color(0xffff0000),
    this.ganttSectionBkgColors = const <Color>[
      Color(0x196666ff),
      Color(0x33ffffff),
      Color(0x33fff400),
      Color(0x33ffffff),
    ],
    this.sequenceAltFrameColor = const Color(0x11888888),
    this.gitMergeInnerColor = const Color(0xffffffff),
    this.railroadSpecialFill = const Color(0xfff0e0ff),
    this.railroadSpecialStroke = const Color(0xff8800cc),
    this.radarGraticuleColor = const Color(0xffdedede),
    this.packetBlockFill = const Color(0xffefefef),
    this.packetBlockBorder = const Color(0xff000000),
    this.packetTextColor = const Color(0xff000000),
    this.kanbanPriorityVeryHigh = const Color(0xffff0000),
    this.kanbanPriorityHigh = const Color(0xffffa500),
    this.kanbanPriorityLow = const Color(0xff0000ff),
    this.kanbanPriorityVeryLow = const Color(0xffadd8e6),
    this.c4PersonFill = const Color(0xff08427b),
    this.c4PersonBorder = const Color(0xff073b6f),
    this.c4PersonExtFill = const Color(0xff686868),
    this.c4PersonExtBorder = const Color(0xff8a8a8a),
    this.c4SystemFill = const Color(0xff1168bd),
    this.c4SystemBorder = const Color(0xff3c7fc0),
    this.c4SystemExtFill = const Color(0xff999999),
    this.c4SystemExtBorder = const Color(0xff8a8a8a),
    this.c4QueueFill = const Color(0xff1168bd),
    this.c4QueueBorder = const Color(0xff3c7fc0),
    this.c4ContainerFill = const Color(0xff438dd5),
    this.c4ContainerBorder = const Color(0xff3c7fc0),
    this.c4ComponentFill = const Color(0xff85bbf0),
    this.c4ComponentBorder = const Color(0xff78a8d8),
    this.c4ExternalPersonFill = const Color(0xff686868),
    this.c4ExternalPersonBorder = const Color(0xff8a8a8a),
    this.c4ExternalSystemFill = const Color(0xff999999),
    this.c4ExternalSystemBorder = const Color(0xff8a8a8a),
    this.c4ExternalContainerFill = const Color(0xffb3b3b3),
    this.c4ExternalContainerBorder = const Color(0xffa6a6a6),
    this.c4ExternalComponentFill = const Color(0xffcccccc),
    this.c4ExternalComponentBorder = const Color(0xffbfbfbf),
    this.c4BoundaryColor = const Color(0xff444444),
    this.c4TextColor = const Color(0xff444444),
    this.wardleyAxisColor = const Color(0xff000000),
    this.wardleyAxisTextColor = const Color(0xff222222),
    this.wardleyComponentFill = const Color(0xffffffff),
    this.wardleyComponentStroke = const Color(0xff000000),
    this.wardleyComponentLabelColor = const Color(0xff222222),
    this.wardleyLinkStroke = const Color(0xff000000),
    this.wardleyEvolutionStroke = const Color(0xffdc3545),
    this.wardleyAnnotationStroke = const Color(0xff000000),
    this.wardleyOutsourceFill = const Color(0xff666666),
    this.wardleyBuyFill = const Color(0xffcccccc),
    this.wardleyBuildFill = const Color(0xffeeeeee),
    this.emUiFill = const Color(0xffffffff),
    this.emUiStroke = const Color(0xffdbdada),
    this.emProcessorFill = const Color(0xffedb3f6),
    this.emProcessorStroke = const Color(0xffb88cbf),
    this.emReadModelFill = const Color(0xffd3f1a2),
    this.emReadModelStroke = const Color(0xffa3b732),
    this.emCommandFill = const Color(0xffbcd6fe),
    this.emCommandStroke = const Color(0xff679ac3),
    this.emEventFill = const Color(0xffffb778),
    this.emUnknownTypeFill = const Color(0xffff0000),
    this.emEventStroke = const Color(0xffc19a0f),
    this.emSwimlaneBackgroundOdd = const Color(0xfffafafa),
    this.emSwimlaneBackgroundStroke = const Color(0xfff0f0f0),
    this.journeyFaceFill = const Color(0xffFFF8DC),
    this.journeyFaceBorder = const Color(0xff999999),
    this.journeyFaceEyeColor = const Color(0xff666666),
    this.journeyActorColors = const <Color>[
      Color(0xff8FBC8F),
      Color(0xff7CFC00),
      Color(0xff00FFFF),
      Color(0xff20B2AA),
      Color(0xffB0E0E6),
      Color(0xffFFFFE0),
    ],
    this.sankeyColorPalette = const <Color>[
      Color(0xff4e79a7),
      Color(0xfff28e2c),
      Color(0xffe15759),
      Color(0xff76b7b2),
      Color(0xff59a14f),
      Color(0xffedc949),
      Color(0xffaf7aa1),
      Color(0xffff9da7),
      Color(0xff9c755f),
      Color(0xffbab0ab),
    ],
    this.cynefinComplexFill = const Color(0xffE8F5E9),
    this.cynefinComplicatedFill = const Color(0xffE3F2FD),
    this.cynefinClearFill = const Color(0xffFFF8E1),
    this.cynefinChaoticFill = const Color(0xffFBE9E7),
    this.cynefinConfusionFill = const Color(0xffF3E5F5),
    this.cynefinCliffColor = const Color(0xff8B0000),
  });

  final Color background;
  final Color primaryColor;
  final Color primaryTextColor;
  final Color primaryBorderColor;
  final Color secondaryColor;
  final Color lineColor;
  final Color arrowheadColor;
  final Color textColor;
  final Color nodeBorder;
  final Color mainBkg;
  final Color clusterBkg;
  final Color clusterBorder;
  final Color titleColor;
  final Color edgeLabelBackground;
  final String fontFamily;
  final double fontSize;

  /// General ordinal color scale (mindmap, treemap, radar, timeline, etc.).
  final Color cScale0;
  final Color cScale1;
  final Color cScale2;
  final Color cScale3;
  final Color cScale4;
  final Color cScale5;
  final Color cScale6;
  final Color cScale7;
  final Color cScale8;
  final Color cScale9;
  final Color cScale10;
  final Color cScale11;
  final Color cScaleInv0;
  final Color cScaleInv1;
  final Color cScaleInv2;
  final Color cScaleInv3;
  final Color cScaleInv4;
  final Color cScaleInv5;
  final Color cScaleInv6;
  final Color cScaleInv7;
  final Color cScaleInv8;
  final Color cScaleInv9;
  final Color cScaleInv10;
  final Color cScaleInv11;
  final Color cScaleLabel0;
  final Color cScaleLabel1;
  final Color cScaleLabel2;
  final Color cScaleLabel3;
  final Color cScaleLabel4;
  final Color cScaleLabel5;
  final Color cScaleLabel6;
  final Color cScaleLabel7;
  final Color cScaleLabel8;
  final Color cScaleLabel9;
  final Color cScaleLabel10;
  final Color cScaleLabel11;
  final Color cScalePeer0;
  final Color cScalePeer1;
  final Color cScalePeer2;
  final Color cScalePeer3;
  final Color cScalePeer4;
  final Color cScalePeer5;
  final Color cScalePeer6;
  final Color cScalePeer7;
  final Color cScalePeer8;
  final Color cScalePeer9;
  final Color cScalePeer10;
  final Color cScalePeer11;

  /// Pie chart palette and text/stroke colors.
  final Color pie1;
  final Color pie2;
  final Color pie3;
  final Color pie4;
  final Color pie5;
  final Color pie6;
  final Color pie7;
  final Color pie8;
  final Color pie9;
  final Color pie10;
  final Color pie11;
  final Color pie12;
  final Color pieStrokeColor;
  final Color pieOuterStrokeColor;
  final Color pieSectionTextColor;
  final Color pieLegendTextColor;
  final Color pieTitleTextColor;

  /// Git graph branch/commit/tag colors.
  final Color git0;
  final Color git1;
  final Color git2;
  final Color git3;
  final Color git4;
  final Color git5;
  final Color git6;
  final Color git7;
  final Color gitInv0;
  final Color gitInv1;
  final Color gitInv2;
  final Color gitInv3;
  final Color gitInv4;
  final Color gitInv5;
  final Color gitInv6;
  final Color gitInv7;
  final Color gitBranchLabel0;
  final Color gitBranchLabel1;
  final Color gitBranchLabel2;
  final Color gitBranchLabel3;
  final Color gitBranchLabel4;
  final Color gitBranchLabel5;
  final Color gitBranchLabel6;
  final Color gitBranchLabel7;
  final Color commitLabelColor;
  final Color commitLabelBackground;
  final Color tagLabelColor;
  final Color tagLabelBackground;
  final Color tagLabelBorder;

  /// Sequence diagram actor/signal/note/activation colors.
  final Color actorBkg;
  final Color actorBorder;
  final Color actorTextColor;
  final Color actorLineColor;
  final Color signalColor;
  final Color signalTextColor;
  final Color labelBoxBkgColor;
  final Color labelBoxBorderColor;
  final Color labelTextColor;
  final Color loopTextColor;
  final Color noteBkgColor;
  final Color noteBorderColor;
  final Color noteTextColor;
  final Color activationBkgColor;
  final Color activationBorderColor;

  /// User-journey section fill colors.
  final Color fillType0;
  final Color fillType1;
  final Color fillType2;
  final Color fillType3;
  final Color fillType4;
  final Color fillType5;
  final Color fillType6;
  final Color fillType7;

  /// Quadrant chart fills and axis/point/title text colors.
  final Color quadrant1Fill;
  final Color quadrant2Fill;
  final Color quadrant3Fill;
  final Color quadrant4Fill;
  final Color quadrant1TextFill;
  final Color quadrant2TextFill;
  final Color quadrant3TextFill;
  final Color quadrant4TextFill;
  final Color quadrantPointFill;
  final Color quadrantPointTextFill;
  final Color quadrantXAxisTextFill;
  final Color quadrantYAxisTextFill;
  final Color quadrantInternalBorderStrokeFill;
  final Color quadrantExternalBorderStrokeFill;
  final Color quadrantTitleFill;

  /// Entity-relationship attribute/row background colors.
  final Color attributeBackgroundColorOdd;
  final Color attributeBackgroundColorEven;
  final Color rowOdd;
  final Color rowEven;

  /// Venn diagram set fills and text colors.
  final Color venn1;
  final Color venn2;
  final Color venn3;
  final Color venn4;
  final Color venn5;
  final Color venn6;
  final Color venn7;
  final Color venn8;
  final Color vennTitleTextColor;
  final Color vennSetTextColor;

  /// Requirement diagram fill/border/text and relation colors.
  final Color requirementBackground;
  final Color requirementBorderColor;
  final Color requirementTextColor;
  final Color relationColor;
  final Color relationLabelBackground;
  final Color relationLabelColor;

  /// xychart plot (bar/line) ordinal palette; upstream `xyChart.plotColorPalette`.
  final List<Color> xyChartPlotColorPalette;

  /// Opaque color of the surface the diagram is painted on.
  ///
  /// Upstream paints knockout glyphs (the git merge inner ring, the ER
  /// relationship leaf) with the theme background. A transparent
  /// background would erase them, so they use this token instead.
  final Color canvasColor;

  /// Text color for a label painted on a dark fill.
  ///
  /// Chosen by fill luminance wherever a diagram paints a label on a
  /// user-supplied fill (mindmap `classDef`, kanban cards, …).
  final Color textOnDarkFill;

  /// Text color for a label painted on a light fill. Counterpart of
  /// [textOnDarkFill].
  final Color textOnLightFill;

  /// Tertiary surface, upstream `tertiaryColor`.
  final Color tertiaryColor;

  /// Gantt task bar fill.
  final Color ganttTaskBkgColor;

  /// Gantt task bar border.
  final Color ganttTaskBorderColor;

  /// Gantt active task fill.
  final Color ganttActiveTaskBkgColor;

  /// Gantt active task border.
  final Color ganttActiveTaskBorderColor;

  /// Gantt completed task fill.
  final Color ganttDoneTaskBkgColor;

  /// Gantt completed task border.
  final Color ganttDoneTaskBorderColor;

  /// Gantt critical task fill.
  final Color ganttCritBkgColor;

  /// Gantt critical task border.
  final Color ganttCritBorderColor;

  /// Gantt label inside a normal task bar.
  final Color ganttTaskTextColor;

  /// Gantt label inside an active task bar.
  final Color ganttActiveTaskTextColor;

  /// Gantt label inside a completed task bar.
  final Color ganttDoneTaskTextColor;

  /// Gantt label inside a critical task bar.
  final Color ganttCritTaskTextColor;

  /// Gantt label drawn outside the task bar.
  ///
  /// This label sits on the diagram canvas rather than on a task fill,
  /// so it has to stay legible against whatever the canvas is.
  final Color ganttTaskTextOutsideColor;

  /// Gantt excluded-day wash.
  final Color ganttExcludeBkgColor;

  /// Gantt grid line stroke.
  final Color ganttGridColor;

  /// Gantt "today" marker line.
  final Color ganttTodayLineColor;

  /// Gantt section band fills, cycled per section.
  final List<Color> ganttSectionBkgColors;

  /// Fill of a sequence `rect` frame that declares no color of its own.
  final Color sequenceAltFrameColor;

  /// Ink of the git merge glyph's inner ring and cross.
  final Color gitMergeInnerColor;

  /// Railroad special-node fill.
  final Color railroadSpecialFill;

  /// Railroad special-node border.
  final Color railroadSpecialStroke;

  /// Radar graticule stroke and fill.
  final Color radarGraticuleColor;

  /// Packet block fill.
  final Color packetBlockFill;

  /// Packet block border.
  final Color packetBlockBorder;

  /// Packet label, byte number and title.
  final Color packetTextColor;

  /// Kanban left-edge bar for the `Very High` priority.
  final Color kanbanPriorityVeryHigh;

  /// Kanban left-edge bar for the `High` priority.
  final Color kanbanPriorityHigh;

  /// Kanban left-edge bar for the `Low` priority.
  final Color kanbanPriorityLow;

  /// Kanban left-edge bar for the `Very Low` priority.
  final Color kanbanPriorityVeryLow;

  /// C4 person element fill.
  final Color c4PersonFill;

  /// C4 person element border.
  final Color c4PersonBorder;

  /// C4 external person element fill.
  final Color c4PersonExtFill;

  /// C4 external person element border.
  final Color c4PersonExtBorder;

  /// C4 system element fill.
  final Color c4SystemFill;

  /// C4 system element border.
  final Color c4SystemBorder;

  /// C4 external system element fill.
  final Color c4SystemExtFill;

  /// C4 external system element border.
  final Color c4SystemExtBorder;

  /// C4 queue element fill.
  final Color c4QueueFill;

  /// C4 queue element border.
  final Color c4QueueBorder;

  /// C4 container element fill.
  final Color c4ContainerFill;

  /// C4 container element border.
  final Color c4ContainerBorder;

  /// C4 component element fill.
  final Color c4ComponentFill;

  /// C4 component element border.
  final Color c4ComponentBorder;

  /// C4 person element fill in an external system.
  final Color c4ExternalPersonFill;

  /// C4 person element border in an external system.
  final Color c4ExternalPersonBorder;

  /// C4 system element fill in an external system.
  final Color c4ExternalSystemFill;

  /// C4 system element border in an external system.
  final Color c4ExternalSystemBorder;

  /// C4 container element fill in an external system.
  final Color c4ExternalContainerFill;

  /// C4 container element border in an external system.
  final Color c4ExternalContainerBorder;

  /// C4 component element fill in an external system.
  final Color c4ExternalComponentFill;

  /// C4 component element border in an external system.
  final Color c4ExternalComponentBorder;

  /// C4 boundary box border.
  final Color c4BoundaryColor;

  /// C4 boundary label and relation text.
  final Color c4TextColor;

  /// Wardley axis stroke.
  final Color wardleyAxisColor;

  /// Wardley axis label color.
  final Color wardleyAxisTextColor;

  /// Wardley component fill.
  final Color wardleyComponentFill;

  /// Wardley component border.
  final Color wardleyComponentStroke;

  /// Wardley component label.
  final Color wardleyComponentLabelColor;

  /// Wardley link stroke.
  final Color wardleyLinkStroke;

  /// Wardley evolution arrow stroke.
  final Color wardleyEvolutionStroke;

  /// Wardley annotation stroke.
  final Color wardleyAnnotationStroke;

  /// Wardley source-strategy overlay for `outsource`.
  final Color wardleyOutsourceFill;

  /// Wardley source-strategy overlay for `buy`.
  final Color wardleyBuyFill;

  /// Wardley source-strategy overlay for `build`.
  final Color wardleyBuildFill;

  /// Event modeling UI entity fill.
  final Color emUiFill;

  /// Event modeling UI entity border.
  final Color emUiStroke;

  /// Event modeling processor entity fill.
  final Color emProcessorFill;

  /// Event modeling processor entity border.
  final Color emProcessorStroke;

  /// Event modeling read model entity fill.
  final Color emReadModelFill;

  /// Event modeling read model entity border.
  final Color emReadModelStroke;

  /// Event modeling command entity fill.
  final Color emCommandFill;

  /// Event modeling command entity border.
  final Color emCommandStroke;

  /// Event modeling event entity fill.
  final Color emEventFill;

  /// Event modeling event entity border.
  final Color emEventStroke;

  /// Fill of an event-modeling entity whose type is not one of the
  /// five known kinds. The red marks the diagram as wrong rather than
  /// the entity as special.
  final Color emUnknownTypeFill;

  /// Event modeling swimlane band fill.
  final Color emSwimlaneBackgroundOdd;

  /// Event modeling swimlane band border.
  final Color emSwimlaneBackgroundStroke;

  /// Journey face fill for a low score.

  /// Journey face fill for a mid score.

  /// Journey face fill for a high score.

  /// Journey face fill. Upstream paints every face in cornsilk; the
  /// score is carried by the mouth, not by the fill.
  final Color journeyFaceFill;

  /// Journey face border.
  final Color journeyFaceBorder;

  /// Journey face eye and mouth color.
  final Color journeyFaceEyeColor;

  /// Journey actor colors, cycled per actor.
  final List<Color> journeyActorColors;

  /// Sankey node and ribbon palette, cycled per node.
  final List<Color> sankeyColorPalette;

  /// Cynefin complex domain fill.
  final Color cynefinComplexFill;

  /// Cynefin complicated domain fill.
  final Color cynefinComplicatedFill;

  /// Cynefin clear domain fill.
  final Color cynefinClearFill;

  /// Cynefin chaotic domain fill.
  final Color cynefinChaoticFill;

  /// Cynefin confusion domain fill.
  final Color cynefinConfusionFill;

  /// Cynefin cliff edge stroke.
  final Color cynefinCliffColor;

  // --- Convenience list views over the indexed palette fields. ---
  List<Color> get cScale => [
        cScale0,
        cScale1,
        cScale2,
        cScale3,
        cScale4,
        cScale5,
        cScale6,
        cScale7,
        cScale8,
        cScale9,
        cScale10,
        cScale11,
      ];
  List<Color> get cScaleInv => [
        cScaleInv0,
        cScaleInv1,
        cScaleInv2,
        cScaleInv3,
        cScaleInv4,
        cScaleInv5,
        cScaleInv6,
        cScaleInv7,
        cScaleInv8,
        cScaleInv9,
        cScaleInv10,
        cScaleInv11,
      ];
  List<Color> get cScaleLabel => [
        cScaleLabel0,
        cScaleLabel1,
        cScaleLabel2,
        cScaleLabel3,
        cScaleLabel4,
        cScaleLabel5,
        cScaleLabel6,
        cScaleLabel7,
        cScaleLabel8,
        cScaleLabel9,
        cScaleLabel10,
        cScaleLabel11,
      ];
  List<Color> get cScalePeer => [
        cScalePeer0,
        cScalePeer1,
        cScalePeer2,
        cScalePeer3,
        cScalePeer4,
        cScalePeer5,
        cScalePeer6,
        cScalePeer7,
        cScalePeer8,
        cScalePeer9,
        cScalePeer10,
        cScalePeer11,
      ];
  List<Color> get pie => [
        pie1,
        pie2,
        pie3,
        pie4,
        pie5,
        pie6,
        pie7,
        pie8,
        pie9,
        pie10,
        pie11,
        pie12,
      ];
  List<Color> get git => [git0, git1, git2, git3, git4, git5, git6, git7];
  List<Color> get gitInv => [
        gitInv0,
        gitInv1,
        gitInv2,
        gitInv3,
        gitInv4,
        gitInv5,
        gitInv6,
        gitInv7,
      ];
  List<Color> get gitBranchLabel => [
        gitBranchLabel0,
        gitBranchLabel1,
        gitBranchLabel2,
        gitBranchLabel3,
        gitBranchLabel4,
        gitBranchLabel5,
        gitBranchLabel6,
        gitBranchLabel7,
      ];
  List<Color> get fillType => [
        fillType0,
        fillType1,
        fillType2,
        fillType3,
        fillType4,
        fillType5,
        fillType6,
        fillType7,
      ];
  List<Color> get venn => [
        venn1,
        venn2,
        venn3,
        venn4,
        venn5,
        venn6,
        venn7,
        venn8,
      ];

  /// A copy of this theme with the given values replaced.
  ///
  /// Every palette entry is settable here, which is what makes the theme
  /// as customizable as mermaid.js' `themeVariables`: a host can override
  /// any color the port exposes, not just the base sixteen. A null
  /// argument keeps the current value.
  MermaidTheme copyWith({
    Color? background,
    Color? primaryColor,
    Color? primaryTextColor,
    Color? primaryBorderColor,
    Color? secondaryColor,
    Color? lineColor,
    Color? arrowheadColor,
    Color? textColor,
    Color? nodeBorder,
    Color? mainBkg,
    Color? clusterBkg,
    Color? clusterBorder,
    Color? titleColor,
    Color? edgeLabelBackground,
    String? fontFamily,
    double? fontSize,
    Color? cScale0,
    Color? cScale1,
    Color? cScale2,
    Color? cScale3,
    Color? cScale4,
    Color? cScale5,
    Color? cScale6,
    Color? cScale7,
    Color? cScale8,
    Color? cScale9,
    Color? cScale10,
    Color? cScale11,
    Color? cScaleInv0,
    Color? cScaleInv1,
    Color? cScaleInv2,
    Color? cScaleInv3,
    Color? cScaleInv4,
    Color? cScaleInv5,
    Color? cScaleInv6,
    Color? cScaleInv7,
    Color? cScaleInv8,
    Color? cScaleInv9,
    Color? cScaleInv10,
    Color? cScaleInv11,
    Color? cScaleLabel0,
    Color? cScaleLabel1,
    Color? cScaleLabel2,
    Color? cScaleLabel3,
    Color? cScaleLabel4,
    Color? cScaleLabel5,
    Color? cScaleLabel6,
    Color? cScaleLabel7,
    Color? cScaleLabel8,
    Color? cScaleLabel9,
    Color? cScaleLabel10,
    Color? cScaleLabel11,
    Color? cScalePeer0,
    Color? cScalePeer1,
    Color? cScalePeer2,
    Color? cScalePeer3,
    Color? cScalePeer4,
    Color? cScalePeer5,
    Color? cScalePeer6,
    Color? cScalePeer7,
    Color? cScalePeer8,
    Color? cScalePeer9,
    Color? cScalePeer10,
    Color? cScalePeer11,
    Color? pie1,
    Color? pie2,
    Color? pie3,
    Color? pie4,
    Color? pie5,
    Color? pie6,
    Color? pie7,
    Color? pie8,
    Color? pie9,
    Color? pie10,
    Color? pie11,
    Color? pie12,
    Color? pieStrokeColor,
    Color? pieOuterStrokeColor,
    Color? pieSectionTextColor,
    Color? pieLegendTextColor,
    Color? pieTitleTextColor,
    Color? git0,
    Color? git1,
    Color? git2,
    Color? git3,
    Color? git4,
    Color? git5,
    Color? git6,
    Color? git7,
    Color? gitInv0,
    Color? gitInv1,
    Color? gitInv2,
    Color? gitInv3,
    Color? gitInv4,
    Color? gitInv5,
    Color? gitInv6,
    Color? gitInv7,
    Color? gitBranchLabel0,
    Color? gitBranchLabel1,
    Color? gitBranchLabel2,
    Color? gitBranchLabel3,
    Color? gitBranchLabel4,
    Color? gitBranchLabel5,
    Color? gitBranchLabel6,
    Color? gitBranchLabel7,
    Color? commitLabelColor,
    Color? commitLabelBackground,
    Color? tagLabelColor,
    Color? tagLabelBackground,
    Color? tagLabelBorder,
    Color? actorBkg,
    Color? actorBorder,
    Color? actorTextColor,
    Color? actorLineColor,
    Color? signalColor,
    Color? signalTextColor,
    Color? labelBoxBkgColor,
    Color? labelBoxBorderColor,
    Color? labelTextColor,
    Color? loopTextColor,
    Color? noteBkgColor,
    Color? noteBorderColor,
    Color? noteTextColor,
    Color? activationBkgColor,
    Color? activationBorderColor,
    Color? fillType0,
    Color? fillType1,
    Color? fillType2,
    Color? fillType3,
    Color? fillType4,
    Color? fillType5,
    Color? fillType6,
    Color? fillType7,
    Color? quadrant1Fill,
    Color? quadrant2Fill,
    Color? quadrant3Fill,
    Color? quadrant4Fill,
    Color? quadrant1TextFill,
    Color? quadrant2TextFill,
    Color? quadrant3TextFill,
    Color? quadrant4TextFill,
    Color? quadrantPointFill,
    Color? quadrantPointTextFill,
    Color? quadrantXAxisTextFill,
    Color? quadrantYAxisTextFill,
    Color? quadrantInternalBorderStrokeFill,
    Color? quadrantExternalBorderStrokeFill,
    Color? quadrantTitleFill,
    Color? attributeBackgroundColorOdd,
    Color? attributeBackgroundColorEven,
    Color? rowOdd,
    Color? rowEven,
    Color? venn1,
    Color? venn2,
    Color? venn3,
    Color? venn4,
    Color? venn5,
    Color? venn6,
    Color? venn7,
    Color? venn8,
    Color? vennTitleTextColor,
    Color? vennSetTextColor,
    Color? requirementBackground,
    Color? requirementBorderColor,
    Color? requirementTextColor,
    Color? relationColor,
    Color? relationLabelBackground,
    Color? relationLabelColor,
    List<Color>? xyChartPlotColorPalette,
    Color? canvasColor,
    Color? textOnDarkFill,
    Color? textOnLightFill,
    Color? tertiaryColor,
    Color? ganttTaskBkgColor,
    Color? ganttTaskBorderColor,
    Color? ganttActiveTaskBkgColor,
    Color? ganttActiveTaskBorderColor,
    Color? ganttDoneTaskBkgColor,
    Color? ganttDoneTaskBorderColor,
    Color? ganttCritBkgColor,
    Color? ganttCritBorderColor,
    Color? ganttTaskTextColor,
    Color? ganttActiveTaskTextColor,
    Color? ganttDoneTaskTextColor,
    Color? ganttCritTaskTextColor,
    Color? ganttTaskTextOutsideColor,
    Color? ganttExcludeBkgColor,
    Color? ganttGridColor,
    Color? ganttTodayLineColor,
    List<Color>? ganttSectionBkgColors,
    Color? sequenceAltFrameColor,
    Color? gitMergeInnerColor,
    Color? railroadSpecialFill,
    Color? railroadSpecialStroke,
    Color? radarGraticuleColor,
    Color? packetBlockFill,
    Color? packetBlockBorder,
    Color? packetTextColor,
    Color? kanbanPriorityVeryHigh,
    Color? kanbanPriorityHigh,
    Color? kanbanPriorityLow,
    Color? kanbanPriorityVeryLow,
    Color? c4PersonFill,
    Color? c4PersonBorder,
    Color? c4PersonExtFill,
    Color? c4PersonExtBorder,
    Color? c4SystemFill,
    Color? c4SystemBorder,
    Color? c4SystemExtFill,
    Color? c4SystemExtBorder,
    Color? c4QueueFill,
    Color? c4QueueBorder,
    Color? c4ContainerFill,
    Color? c4ContainerBorder,
    Color? c4ComponentFill,
    Color? c4ComponentBorder,
    Color? c4ExternalPersonFill,
    Color? c4ExternalPersonBorder,
    Color? c4ExternalSystemFill,
    Color? c4ExternalSystemBorder,
    Color? c4ExternalContainerFill,
    Color? c4ExternalContainerBorder,
    Color? c4ExternalComponentFill,
    Color? c4ExternalComponentBorder,
    Color? c4BoundaryColor,
    Color? c4TextColor,
    Color? wardleyAxisColor,
    Color? wardleyAxisTextColor,
    Color? wardleyComponentFill,
    Color? wardleyComponentStroke,
    Color? wardleyComponentLabelColor,
    Color? wardleyLinkStroke,
    Color? wardleyEvolutionStroke,
    Color? wardleyAnnotationStroke,
    Color? wardleyOutsourceFill,
    Color? wardleyBuyFill,
    Color? wardleyBuildFill,
    Color? emUiFill,
    Color? emUiStroke,
    Color? emProcessorFill,
    Color? emProcessorStroke,
    Color? emReadModelFill,
    Color? emReadModelStroke,
    Color? emCommandFill,
    Color? emCommandStroke,
    Color? emEventFill,
    Color? emEventStroke,
    Color? emUnknownTypeFill,
    Color? emSwimlaneBackgroundOdd,
    Color? emSwimlaneBackgroundStroke,
    Color? journeyFaceFill,
    Color? journeyFaceBorder,
    Color? journeyFaceEyeColor,
    List<Color>? journeyActorColors,
    List<Color>? sankeyColorPalette,
    Color? cynefinComplexFill,
    Color? cynefinComplicatedFill,
    Color? cynefinClearFill,
    Color? cynefinChaoticFill,
    Color? cynefinConfusionFill,
    Color? cynefinCliffColor,
  }) =>
      MermaidTheme(
        background: background ?? this.background,
        primaryColor: primaryColor ?? this.primaryColor,
        primaryTextColor: primaryTextColor ?? this.primaryTextColor,
        primaryBorderColor: primaryBorderColor ?? this.primaryBorderColor,
        secondaryColor: secondaryColor ?? this.secondaryColor,
        lineColor: lineColor ?? this.lineColor,
        arrowheadColor: arrowheadColor ?? this.arrowheadColor,
        textColor: textColor ?? this.textColor,
        nodeBorder: nodeBorder ?? this.nodeBorder,
        mainBkg: mainBkg ?? this.mainBkg,
        clusterBkg: clusterBkg ?? this.clusterBkg,
        clusterBorder: clusterBorder ?? this.clusterBorder,
        titleColor: titleColor ?? this.titleColor,
        edgeLabelBackground: edgeLabelBackground ?? this.edgeLabelBackground,
        fontFamily: fontFamily ?? this.fontFamily,
        fontSize: fontSize ?? this.fontSize,
        cScale0: cScale0 ?? this.cScale0,
        cScale1: cScale1 ?? this.cScale1,
        cScale2: cScale2 ?? this.cScale2,
        cScale3: cScale3 ?? this.cScale3,
        cScale4: cScale4 ?? this.cScale4,
        cScale5: cScale5 ?? this.cScale5,
        cScale6: cScale6 ?? this.cScale6,
        cScale7: cScale7 ?? this.cScale7,
        cScale8: cScale8 ?? this.cScale8,
        cScale9: cScale9 ?? this.cScale9,
        cScale10: cScale10 ?? this.cScale10,
        cScale11: cScale11 ?? this.cScale11,
        cScaleInv0: cScaleInv0 ?? this.cScaleInv0,
        cScaleInv1: cScaleInv1 ?? this.cScaleInv1,
        cScaleInv2: cScaleInv2 ?? this.cScaleInv2,
        cScaleInv3: cScaleInv3 ?? this.cScaleInv3,
        cScaleInv4: cScaleInv4 ?? this.cScaleInv4,
        cScaleInv5: cScaleInv5 ?? this.cScaleInv5,
        cScaleInv6: cScaleInv6 ?? this.cScaleInv6,
        cScaleInv7: cScaleInv7 ?? this.cScaleInv7,
        cScaleInv8: cScaleInv8 ?? this.cScaleInv8,
        cScaleInv9: cScaleInv9 ?? this.cScaleInv9,
        cScaleInv10: cScaleInv10 ?? this.cScaleInv10,
        cScaleInv11: cScaleInv11 ?? this.cScaleInv11,
        cScaleLabel0: cScaleLabel0 ?? this.cScaleLabel0,
        cScaleLabel1: cScaleLabel1 ?? this.cScaleLabel1,
        cScaleLabel2: cScaleLabel2 ?? this.cScaleLabel2,
        cScaleLabel3: cScaleLabel3 ?? this.cScaleLabel3,
        cScaleLabel4: cScaleLabel4 ?? this.cScaleLabel4,
        cScaleLabel5: cScaleLabel5 ?? this.cScaleLabel5,
        cScaleLabel6: cScaleLabel6 ?? this.cScaleLabel6,
        cScaleLabel7: cScaleLabel7 ?? this.cScaleLabel7,
        cScaleLabel8: cScaleLabel8 ?? this.cScaleLabel8,
        cScaleLabel9: cScaleLabel9 ?? this.cScaleLabel9,
        cScaleLabel10: cScaleLabel10 ?? this.cScaleLabel10,
        cScaleLabel11: cScaleLabel11 ?? this.cScaleLabel11,
        cScalePeer0: cScalePeer0 ?? this.cScalePeer0,
        cScalePeer1: cScalePeer1 ?? this.cScalePeer1,
        cScalePeer2: cScalePeer2 ?? this.cScalePeer2,
        cScalePeer3: cScalePeer3 ?? this.cScalePeer3,
        cScalePeer4: cScalePeer4 ?? this.cScalePeer4,
        cScalePeer5: cScalePeer5 ?? this.cScalePeer5,
        cScalePeer6: cScalePeer6 ?? this.cScalePeer6,
        cScalePeer7: cScalePeer7 ?? this.cScalePeer7,
        cScalePeer8: cScalePeer8 ?? this.cScalePeer8,
        cScalePeer9: cScalePeer9 ?? this.cScalePeer9,
        cScalePeer10: cScalePeer10 ?? this.cScalePeer10,
        cScalePeer11: cScalePeer11 ?? this.cScalePeer11,
        pie1: pie1 ?? this.pie1,
        pie2: pie2 ?? this.pie2,
        pie3: pie3 ?? this.pie3,
        pie4: pie4 ?? this.pie4,
        pie5: pie5 ?? this.pie5,
        pie6: pie6 ?? this.pie6,
        pie7: pie7 ?? this.pie7,
        pie8: pie8 ?? this.pie8,
        pie9: pie9 ?? this.pie9,
        pie10: pie10 ?? this.pie10,
        pie11: pie11 ?? this.pie11,
        pie12: pie12 ?? this.pie12,
        pieStrokeColor: pieStrokeColor ?? this.pieStrokeColor,
        pieOuterStrokeColor: pieOuterStrokeColor ?? this.pieOuterStrokeColor,
        pieSectionTextColor: pieSectionTextColor ?? this.pieSectionTextColor,
        pieLegendTextColor: pieLegendTextColor ?? this.pieLegendTextColor,
        pieTitleTextColor: pieTitleTextColor ?? this.pieTitleTextColor,
        git0: git0 ?? this.git0,
        git1: git1 ?? this.git1,
        git2: git2 ?? this.git2,
        git3: git3 ?? this.git3,
        git4: git4 ?? this.git4,
        git5: git5 ?? this.git5,
        git6: git6 ?? this.git6,
        git7: git7 ?? this.git7,
        gitInv0: gitInv0 ?? this.gitInv0,
        gitInv1: gitInv1 ?? this.gitInv1,
        gitInv2: gitInv2 ?? this.gitInv2,
        gitInv3: gitInv3 ?? this.gitInv3,
        gitInv4: gitInv4 ?? this.gitInv4,
        gitInv5: gitInv5 ?? this.gitInv5,
        gitInv6: gitInv6 ?? this.gitInv6,
        gitInv7: gitInv7 ?? this.gitInv7,
        gitBranchLabel0: gitBranchLabel0 ?? this.gitBranchLabel0,
        gitBranchLabel1: gitBranchLabel1 ?? this.gitBranchLabel1,
        gitBranchLabel2: gitBranchLabel2 ?? this.gitBranchLabel2,
        gitBranchLabel3: gitBranchLabel3 ?? this.gitBranchLabel3,
        gitBranchLabel4: gitBranchLabel4 ?? this.gitBranchLabel4,
        gitBranchLabel5: gitBranchLabel5 ?? this.gitBranchLabel5,
        gitBranchLabel6: gitBranchLabel6 ?? this.gitBranchLabel6,
        gitBranchLabel7: gitBranchLabel7 ?? this.gitBranchLabel7,
        commitLabelColor: commitLabelColor ?? this.commitLabelColor,
        commitLabelBackground:
            commitLabelBackground ?? this.commitLabelBackground,
        tagLabelColor: tagLabelColor ?? this.tagLabelColor,
        tagLabelBackground: tagLabelBackground ?? this.tagLabelBackground,
        tagLabelBorder: tagLabelBorder ?? this.tagLabelBorder,
        actorBkg: actorBkg ?? this.actorBkg,
        actorBorder: actorBorder ?? this.actorBorder,
        actorTextColor: actorTextColor ?? this.actorTextColor,
        actorLineColor: actorLineColor ?? this.actorLineColor,
        signalColor: signalColor ?? this.signalColor,
        signalTextColor: signalTextColor ?? this.signalTextColor,
        labelBoxBkgColor: labelBoxBkgColor ?? this.labelBoxBkgColor,
        labelBoxBorderColor: labelBoxBorderColor ?? this.labelBoxBorderColor,
        labelTextColor: labelTextColor ?? this.labelTextColor,
        loopTextColor: loopTextColor ?? this.loopTextColor,
        noteBkgColor: noteBkgColor ?? this.noteBkgColor,
        noteBorderColor: noteBorderColor ?? this.noteBorderColor,
        noteTextColor: noteTextColor ?? this.noteTextColor,
        activationBkgColor: activationBkgColor ?? this.activationBkgColor,
        activationBorderColor:
            activationBorderColor ?? this.activationBorderColor,
        fillType0: fillType0 ?? this.fillType0,
        fillType1: fillType1 ?? this.fillType1,
        fillType2: fillType2 ?? this.fillType2,
        fillType3: fillType3 ?? this.fillType3,
        fillType4: fillType4 ?? this.fillType4,
        fillType5: fillType5 ?? this.fillType5,
        fillType6: fillType6 ?? this.fillType6,
        fillType7: fillType7 ?? this.fillType7,
        quadrant1Fill: quadrant1Fill ?? this.quadrant1Fill,
        quadrant2Fill: quadrant2Fill ?? this.quadrant2Fill,
        quadrant3Fill: quadrant3Fill ?? this.quadrant3Fill,
        quadrant4Fill: quadrant4Fill ?? this.quadrant4Fill,
        quadrant1TextFill: quadrant1TextFill ?? this.quadrant1TextFill,
        quadrant2TextFill: quadrant2TextFill ?? this.quadrant2TextFill,
        quadrant3TextFill: quadrant3TextFill ?? this.quadrant3TextFill,
        quadrant4TextFill: quadrant4TextFill ?? this.quadrant4TextFill,
        quadrantPointFill: quadrantPointFill ?? this.quadrantPointFill,
        quadrantPointTextFill:
            quadrantPointTextFill ?? this.quadrantPointTextFill,
        quadrantXAxisTextFill:
            quadrantXAxisTextFill ?? this.quadrantXAxisTextFill,
        quadrantYAxisTextFill:
            quadrantYAxisTextFill ?? this.quadrantYAxisTextFill,
        quadrantInternalBorderStrokeFill: quadrantInternalBorderStrokeFill ??
            this.quadrantInternalBorderStrokeFill,
        quadrantExternalBorderStrokeFill: quadrantExternalBorderStrokeFill ??
            this.quadrantExternalBorderStrokeFill,
        quadrantTitleFill: quadrantTitleFill ?? this.quadrantTitleFill,
        attributeBackgroundColorOdd:
            attributeBackgroundColorOdd ?? this.attributeBackgroundColorOdd,
        attributeBackgroundColorEven:
            attributeBackgroundColorEven ?? this.attributeBackgroundColorEven,
        rowOdd: rowOdd ?? this.rowOdd,
        rowEven: rowEven ?? this.rowEven,
        venn1: venn1 ?? this.venn1,
        venn2: venn2 ?? this.venn2,
        venn3: venn3 ?? this.venn3,
        venn4: venn4 ?? this.venn4,
        venn5: venn5 ?? this.venn5,
        venn6: venn6 ?? this.venn6,
        venn7: venn7 ?? this.venn7,
        venn8: venn8 ?? this.venn8,
        vennTitleTextColor: vennTitleTextColor ?? this.vennTitleTextColor,
        vennSetTextColor: vennSetTextColor ?? this.vennSetTextColor,
        requirementBackground:
            requirementBackground ?? this.requirementBackground,
        requirementBorderColor:
            requirementBorderColor ?? this.requirementBorderColor,
        requirementTextColor: requirementTextColor ?? this.requirementTextColor,
        relationColor: relationColor ?? this.relationColor,
        relationLabelBackground:
            relationLabelBackground ?? this.relationLabelBackground,
        relationLabelColor: relationLabelColor ?? this.relationLabelColor,
        xyChartPlotColorPalette:
            xyChartPlotColorPalette ?? this.xyChartPlotColorPalette,
        canvasColor: canvasColor ?? this.canvasColor,
        textOnDarkFill: textOnDarkFill ?? this.textOnDarkFill,
        textOnLightFill: textOnLightFill ?? this.textOnLightFill,
        tertiaryColor: tertiaryColor ?? this.tertiaryColor,
        ganttTaskBkgColor: ganttTaskBkgColor ?? this.ganttTaskBkgColor,
        ganttTaskBorderColor: ganttTaskBorderColor ?? this.ganttTaskBorderColor,
        ganttActiveTaskBkgColor:
            ganttActiveTaskBkgColor ?? this.ganttActiveTaskBkgColor,
        ganttActiveTaskBorderColor:
            ganttActiveTaskBorderColor ?? this.ganttActiveTaskBorderColor,
        ganttDoneTaskBkgColor:
            ganttDoneTaskBkgColor ?? this.ganttDoneTaskBkgColor,
        ganttDoneTaskBorderColor:
            ganttDoneTaskBorderColor ?? this.ganttDoneTaskBorderColor,
        ganttCritBkgColor: ganttCritBkgColor ?? this.ganttCritBkgColor,
        ganttCritBorderColor: ganttCritBorderColor ?? this.ganttCritBorderColor,
        ganttTaskTextColor: ganttTaskTextColor ?? this.ganttTaskTextColor,
        ganttActiveTaskTextColor:
            ganttActiveTaskTextColor ?? this.ganttActiveTaskTextColor,
        ganttDoneTaskTextColor:
            ganttDoneTaskTextColor ?? this.ganttDoneTaskTextColor,
        ganttCritTaskTextColor:
            ganttCritTaskTextColor ?? this.ganttCritTaskTextColor,
        ganttTaskTextOutsideColor:
            ganttTaskTextOutsideColor ?? this.ganttTaskTextOutsideColor,
        ganttExcludeBkgColor: ganttExcludeBkgColor ?? this.ganttExcludeBkgColor,
        ganttGridColor: ganttGridColor ?? this.ganttGridColor,
        ganttTodayLineColor: ganttTodayLineColor ?? this.ganttTodayLineColor,
        ganttSectionBkgColors:
            ganttSectionBkgColors ?? this.ganttSectionBkgColors,
        sequenceAltFrameColor:
            sequenceAltFrameColor ?? this.sequenceAltFrameColor,
        gitMergeInnerColor: gitMergeInnerColor ?? this.gitMergeInnerColor,
        railroadSpecialFill: railroadSpecialFill ?? this.railroadSpecialFill,
        railroadSpecialStroke:
            railroadSpecialStroke ?? this.railroadSpecialStroke,
        radarGraticuleColor: radarGraticuleColor ?? this.radarGraticuleColor,
        packetBlockFill: packetBlockFill ?? this.packetBlockFill,
        packetBlockBorder: packetBlockBorder ?? this.packetBlockBorder,
        packetTextColor: packetTextColor ?? this.packetTextColor,
        kanbanPriorityVeryHigh:
            kanbanPriorityVeryHigh ?? this.kanbanPriorityVeryHigh,
        kanbanPriorityHigh: kanbanPriorityHigh ?? this.kanbanPriorityHigh,
        kanbanPriorityLow: kanbanPriorityLow ?? this.kanbanPriorityLow,
        kanbanPriorityVeryLow:
            kanbanPriorityVeryLow ?? this.kanbanPriorityVeryLow,
        c4PersonFill: c4PersonFill ?? this.c4PersonFill,
        c4PersonBorder: c4PersonBorder ?? this.c4PersonBorder,
        c4PersonExtFill: c4PersonExtFill ?? this.c4PersonExtFill,
        c4PersonExtBorder: c4PersonExtBorder ?? this.c4PersonExtBorder,
        c4SystemFill: c4SystemFill ?? this.c4SystemFill,
        c4SystemBorder: c4SystemBorder ?? this.c4SystemBorder,
        c4SystemExtFill: c4SystemExtFill ?? this.c4SystemExtFill,
        c4SystemExtBorder: c4SystemExtBorder ?? this.c4SystemExtBorder,
        c4QueueFill: c4QueueFill ?? this.c4QueueFill,
        c4QueueBorder: c4QueueBorder ?? this.c4QueueBorder,
        c4ContainerFill: c4ContainerFill ?? this.c4ContainerFill,
        c4ContainerBorder: c4ContainerBorder ?? this.c4ContainerBorder,
        c4ComponentFill: c4ComponentFill ?? this.c4ComponentFill,
        c4ComponentBorder: c4ComponentBorder ?? this.c4ComponentBorder,
        c4ExternalPersonFill: c4ExternalPersonFill ?? this.c4ExternalPersonFill,
        c4ExternalPersonBorder:
            c4ExternalPersonBorder ?? this.c4ExternalPersonBorder,
        c4ExternalSystemFill: c4ExternalSystemFill ?? this.c4ExternalSystemFill,
        c4ExternalSystemBorder:
            c4ExternalSystemBorder ?? this.c4ExternalSystemBorder,
        c4ExternalContainerFill:
            c4ExternalContainerFill ?? this.c4ExternalContainerFill,
        c4ExternalContainerBorder:
            c4ExternalContainerBorder ?? this.c4ExternalContainerBorder,
        c4ExternalComponentFill:
            c4ExternalComponentFill ?? this.c4ExternalComponentFill,
        c4ExternalComponentBorder:
            c4ExternalComponentBorder ?? this.c4ExternalComponentBorder,
        c4BoundaryColor: c4BoundaryColor ?? this.c4BoundaryColor,
        c4TextColor: c4TextColor ?? this.c4TextColor,
        wardleyAxisColor: wardleyAxisColor ?? this.wardleyAxisColor,
        wardleyAxisTextColor: wardleyAxisTextColor ?? this.wardleyAxisTextColor,
        wardleyComponentFill: wardleyComponentFill ?? this.wardleyComponentFill,
        wardleyComponentStroke:
            wardleyComponentStroke ?? this.wardleyComponentStroke,
        wardleyComponentLabelColor:
            wardleyComponentLabelColor ?? this.wardleyComponentLabelColor,
        wardleyLinkStroke: wardleyLinkStroke ?? this.wardleyLinkStroke,
        wardleyEvolutionStroke:
            wardleyEvolutionStroke ?? this.wardleyEvolutionStroke,
        wardleyAnnotationStroke:
            wardleyAnnotationStroke ?? this.wardleyAnnotationStroke,
        wardleyOutsourceFill: wardleyOutsourceFill ?? this.wardleyOutsourceFill,
        wardleyBuyFill: wardleyBuyFill ?? this.wardleyBuyFill,
        wardleyBuildFill: wardleyBuildFill ?? this.wardleyBuildFill,
        emUiFill: emUiFill ?? this.emUiFill,
        emUiStroke: emUiStroke ?? this.emUiStroke,
        emProcessorFill: emProcessorFill ?? this.emProcessorFill,
        emProcessorStroke: emProcessorStroke ?? this.emProcessorStroke,
        emReadModelFill: emReadModelFill ?? this.emReadModelFill,
        emReadModelStroke: emReadModelStroke ?? this.emReadModelStroke,
        emCommandFill: emCommandFill ?? this.emCommandFill,
        emCommandStroke: emCommandStroke ?? this.emCommandStroke,
        emEventFill: emEventFill ?? this.emEventFill,
        emEventStroke: emEventStroke ?? this.emEventStroke,
        emUnknownTypeFill: emUnknownTypeFill ?? this.emUnknownTypeFill,
        emSwimlaneBackgroundOdd:
            emSwimlaneBackgroundOdd ?? this.emSwimlaneBackgroundOdd,
        emSwimlaneBackgroundStroke:
            emSwimlaneBackgroundStroke ?? this.emSwimlaneBackgroundStroke,
        journeyFaceFill: journeyFaceFill ?? this.journeyFaceFill,
        journeyFaceBorder: journeyFaceBorder ?? this.journeyFaceBorder,
        journeyFaceEyeColor: journeyFaceEyeColor ?? this.journeyFaceEyeColor,
        journeyActorColors: journeyActorColors ?? this.journeyActorColors,
        sankeyColorPalette: sankeyColorPalette ?? this.sankeyColorPalette,
        cynefinComplexFill: cynefinComplexFill ?? this.cynefinComplexFill,
        cynefinComplicatedFill:
            cynefinComplicatedFill ?? this.cynefinComplicatedFill,
        cynefinClearFill: cynefinClearFill ?? this.cynefinClearFill,
        cynefinChaoticFill: cynefinChaoticFill ?? this.cynefinChaoticFill,
        cynefinConfusionFill: cynefinConfusionFill ?? this.cynefinConfusionFill,
        cynefinCliffColor: cynefinCliffColor ?? this.cynefinCliffColor,
      );

  List<Object> get _equalityValues => [
        background,
        primaryColor,
        primaryTextColor,
        primaryBorderColor,
        secondaryColor,
        lineColor,
        arrowheadColor,
        textColor,
        nodeBorder,
        mainBkg,
        clusterBkg,
        clusterBorder,
        titleColor,
        edgeLabelBackground,
        fontFamily,
        fontSize,
        ...cScale,
        ...cScaleInv,
        ...cScaleLabel,
        ...cScalePeer,
        ...pie,
        pieStrokeColor,
        pieOuterStrokeColor,
        pieSectionTextColor,
        pieLegendTextColor,
        pieTitleTextColor,
        ...git,
        ...gitInv,
        ...gitBranchLabel,
        commitLabelColor,
        commitLabelBackground,
        tagLabelColor,
        tagLabelBackground,
        tagLabelBorder,
        actorBkg,
        actorBorder,
        actorTextColor,
        actorLineColor,
        signalColor,
        signalTextColor,
        labelBoxBkgColor,
        labelBoxBorderColor,
        labelTextColor,
        loopTextColor,
        noteBkgColor,
        noteBorderColor,
        noteTextColor,
        activationBkgColor,
        activationBorderColor,
        ...fillType,
        quadrant1Fill,
        quadrant2Fill,
        quadrant3Fill,
        quadrant4Fill,
        quadrant1TextFill,
        quadrant2TextFill,
        quadrant3TextFill,
        quadrant4TextFill,
        quadrantPointFill,
        quadrantPointTextFill,
        quadrantXAxisTextFill,
        quadrantYAxisTextFill,
        quadrantInternalBorderStrokeFill,
        quadrantExternalBorderStrokeFill,
        quadrantTitleFill,
        attributeBackgroundColorOdd,
        attributeBackgroundColorEven,
        rowOdd,
        rowEven,
        ...venn,
        vennTitleTextColor,
        vennSetTextColor,
        requirementBackground,
        requirementBorderColor,
        requirementTextColor,
        relationColor,
        relationLabelBackground,
        relationLabelColor,
        ...xyChartPlotColorPalette,
        canvasColor,
        textOnDarkFill,
        textOnLightFill,
        tertiaryColor,
        ganttTaskBkgColor,
        ganttTaskBorderColor,
        ganttActiveTaskBkgColor,
        ganttActiveTaskBorderColor,
        ganttDoneTaskBkgColor,
        ganttDoneTaskBorderColor,
        ganttCritBkgColor,
        ganttCritBorderColor,
        ganttTaskTextColor,
        ganttActiveTaskTextColor,
        ganttDoneTaskTextColor,
        ganttCritTaskTextColor,
        ganttTaskTextOutsideColor,
        ganttExcludeBkgColor,
        ganttGridColor,
        ganttTodayLineColor,
        ...ganttSectionBkgColors,
        sequenceAltFrameColor,
        gitMergeInnerColor,
        railroadSpecialFill,
        railroadSpecialStroke,
        radarGraticuleColor,
        packetBlockFill,
        packetBlockBorder,
        packetTextColor,
        kanbanPriorityVeryHigh,
        kanbanPriorityHigh,
        kanbanPriorityLow,
        kanbanPriorityVeryLow,
        c4PersonFill,
        c4PersonBorder,
        c4PersonExtFill,
        c4PersonExtBorder,
        c4SystemFill,
        c4SystemBorder,
        c4SystemExtFill,
        c4SystemExtBorder,
        c4QueueFill,
        c4QueueBorder,
        c4ContainerFill,
        c4ContainerBorder,
        c4ComponentFill,
        c4ComponentBorder,
        c4ExternalPersonFill,
        c4ExternalPersonBorder,
        c4ExternalSystemFill,
        c4ExternalSystemBorder,
        c4ExternalContainerFill,
        c4ExternalContainerBorder,
        c4ExternalComponentFill,
        c4ExternalComponentBorder,
        c4BoundaryColor,
        c4TextColor,
        wardleyAxisColor,
        wardleyAxisTextColor,
        wardleyComponentFill,
        wardleyComponentStroke,
        wardleyComponentLabelColor,
        wardleyLinkStroke,
        wardleyEvolutionStroke,
        wardleyAnnotationStroke,
        wardleyOutsourceFill,
        wardleyBuyFill,
        wardleyBuildFill,
        emUiFill,
        emUiStroke,
        emProcessorFill,
        emProcessorStroke,
        emReadModelFill,
        emReadModelStroke,
        emCommandFill,
        emCommandStroke,
        emEventFill,
        emEventStroke,
        emUnknownTypeFill,
        emSwimlaneBackgroundOdd,
        emSwimlaneBackgroundStroke,
        journeyFaceFill,
        journeyFaceBorder,
        journeyFaceEyeColor,
        ...journeyActorColors,
        ...sankeyColorPalette,
        cynefinComplexFill,
        cynefinComplicatedFill,
        cynefinClearFill,
        cynefinChaoticFill,
        cynefinConfusionFill,
        cynefinCliffColor,
      ];

  /// Two themes are equal when every palette value matches, not just the base
  /// colors. Building the comparison lists is O(number of fields), so the
  /// common `theme == theme` case short-circuits on identity — Flutter
  /// compares themes on every widget update.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MermaidTheme &&
          _sameValues(other._equalityValues, _equalityValues);

  @override
  int get hashCode => _themeHashCodes[this] ??= Object.hashAll(_equalityValues);

  /// Values from upstream theme-default.js.
  static const MermaidTheme defaultTheme = MermaidTheme(
    background: Color(0xffffffff),
    primaryColor: Color(0xffececff),
    primaryTextColor: Color(0xff131300),
    primaryBorderColor: Color(0xff9370db),
    secondaryColor: Color(0xffffffde),
    lineColor: Color(0xff333333),
    arrowheadColor: Color(0xff333333),
    textColor: Color(0xff333333),
    nodeBorder: Color(0xff9370db),
    mainBkg: Color(0xffececff),
    clusterBkg: Color(0xffffffde),
    clusterBorder: Color(0xffaaaa33),
    titleColor: Color(0xff333333),
    edgeLabelBackground: Color(0xcce8e8e8),
    fontFamily: '"trebuchet ms", verdana, arial, sans-serif',
    fontSize: 16,
  );

  /// Values from upstream theme-dark.js (approximate core subset). Like
  /// upstream, the dark theme paints no background of its own.
  static const MermaidTheme darkTheme = MermaidTheme(
    xyChartPlotColorPalette: _darkXyChartPlotColorPalette,
    // Dark-theme variants of the diagram-specific tokens. Only the values
    // that would be illegible on a dark canvas are overridden: washes that
    // would glare, neutral fills that would swallow their own label, and
    // strokes that would disappear.
    canvasColor: Color(0xff1f2020),
    textOnDarkFill: Color(0xffe0dfdf),
    tertiaryColor: Color(0xff182028),
    ganttExcludeBkgColor: Color(0xff2b2b2b),
    ganttGridColor: Color(0xff4a4a4a),
    gitMergeInnerColor: Color(0xff1f2020),
    railroadSpecialFill: Color(0xff182028),
    railroadSpecialStroke: Color(0xff81b1db),
    radarGraticuleColor: Color(0xff3a3a3a),
    packetBlockFill: Color(0xff333333),
    packetBlockBorder: Color(0xffdddddd),
    packetTextColor: Color(0xffe0e0e0),
    c4BoundaryColor: Color(0xffdddddd),
    c4TextColor: Color(0xffdddddd),
    wardleyAxisColor: Color(0xffcccccc),
    wardleyAxisTextColor: Color(0xffe0e0e0),
    wardleyComponentFill: Color(0xff2a2a2a),
    wardleyComponentStroke: Color(0xffdddddd),
    wardleyComponentLabelColor: Color(0xffe0e0e0),
    wardleyLinkStroke: Color(0xffcccccc),
    wardleyAnnotationStroke: Color(0xffcccccc),
    wardleyOutsourceFill: Color(0xff3a3a3a),
    wardleyBuyFill: Color(0xff2f2f2f),
    wardleyBuildFill: Color(0xff242424),
    emSwimlaneBackgroundOdd: Color(0xff1e1e1e),
    emSwimlaneBackgroundStroke: Color(0xff333333),
    journeyFaceBorder: Color(0xffcccccc),
    journeyFaceEyeColor: Color(0xffcccccc),
    cynefinCliffColor: Color(0xffff6b6b),
    background: Color(0x00000000),
    primaryColor: Color(0xff1f2020),
    primaryTextColor: Color(0xffe0dfdf),
    primaryBorderColor: Color(0xff81b1db),
    secondaryColor: Color(0xff182028),
    lineColor: Color(0xffd3d3d3),
    arrowheadColor: Color(0xffd3d3d3),
    textColor: Color(0xffcccccc),
    nodeBorder: Color(0xff81b1db),
    mainBkg: Color(0xff1f2020),
    clusterBkg: Color(0xff182028),
    clusterBorder: Color(0xff7c0000),
    titleColor: Color(0xfff9fffe),
    edgeLabelBackground: Color(0xff5a5a5a),
    fontFamily: '"trebuchet ms", verdana, arial, sans-serif',
    fontSize: 16,
    cScale0: Color(0xff1f2020),
    cScale1: Color(0xff0b0000),
    cScale2: Color(0xff4d1037),
    cScale3: Color(0xff3f5258),
    cScale4: Color(0xff4f2f1b),
    cScale5: Color(0xff6e0a0a),
    cScale6: Color(0xff3b0048),
    cScale7: Color(0xff995a01),
    cScale8: Color(0xff154706),
    cScale9: Color(0xff161722),
    cScale10: Color(0xff00296f),
    cScale11: Color(0xff01629c),
    cScaleInv0: Color(0xffe0dfdf),
    cScaleInv1: Color(0xfff4ffff),
    cScaleInv2: Color(0xffb2efc8),
    cScaleInv3: Color(0xffc0ada7),
    cScaleInv4: Color(0xffb0d0e4),
    cScaleInv5: Color(0xff91f5f5),
    cScaleInv6: Color(0xffc4ffb7),
    cScaleInv7: Color(0xff66a5fe),
    cScaleInv8: Color(0xffeab8f9),
    cScaleInv9: Color(0xffe9e8dd),
    cScaleInv10: Color(0xffffd690),
    cScaleInv11: Color(0xfffe9d63),
    cScaleLabel0: Color(0xffd3d3d3),
    cScaleLabel1: Color(0xffd3d3d3),
    cScaleLabel2: Color(0xffd3d3d3),
    cScaleLabel3: Color(0xffd3d3d3),
    cScaleLabel4: Color(0xffd3d3d3),
    cScaleLabel5: Color(0xffd3d3d3),
    cScaleLabel6: Color(0xffd3d3d3),
    cScaleLabel7: Color(0xffd3d3d3),
    cScaleLabel8: Color(0xffd3d3d3),
    cScaleLabel9: Color(0xffd3d3d3),
    cScaleLabel10: Color(0xffd3d3d3),
    cScaleLabel11: Color(0xffd3d3d3),
    cScalePeer0: Color(0xff383a3a),
    cScalePeer1: Color(0xff3e0000),
    cScalePeer2: Color(0xff771955),
    cScalePeer3: Color(0xff546e76),
    cScalePeer4: Color(0xff754628),
    cScalePeer5: Color(0xff9d0e0e),
    cScalePeer6: Color(0xff65007b),
    cScalePeer7: Color(0xffcc7801),
    cScalePeer8: Color(0xff23760a),
    cScalePeer9: Color(0xff2a2c41),
    cScalePeer10: Color(0xff003ca2),
    cScalePeer11: Color(0xff0182cf),
    pie1: Color(0xff0b0000),
    pie2: Color(0xff4d1037),
    pie3: Color(0xff3f5258),
    pie4: Color(0xff4f2f1b),
    pie5: Color(0xff6e0a0a),
    pie6: Color(0xff3b0048),
    pie7: Color(0xff995a01),
    pie8: Color(0xff154706),
    pie9: Color(0xff161722),
    pie10: Color(0xff00296f),
    pie11: Color(0xff01629c),
    pie12: Color(0xff1f2020),
    pieStrokeColor: Color(0xff000000),
    pieOuterStrokeColor: Color(0xff000000),
    pieSectionTextColor: Color(0xffcccccc),
    pieLegendTextColor: Color(0xffd3d3d3),
    pieTitleTextColor: Color(0xffd3d3d3),
    git0: Color(0xff797d7d),
    git1: Color(0xffa12273),
    git2: Color(0xff6a8993),
    git3: Color(0xff9b5c35),
    git4: Color(0xffcb1313),
    git5: Color(0xff65007b),
    git6: Color(0xffcc7801),
    git7: Color(0xff31a50e),
    gitInv0: Color(0xff868282),
    gitInv1: Color(0xff5edd8c),
    gitInv2: Color(0xff95766c),
    gitInv3: Color(0xff64a3ca),
    gitInv4: Color(0xff34eded),
    gitInv5: Color(0xff9aff84),
    gitInv6: Color(0xff3387fe),
    gitInv7: Color(0xffce5af1),
    gitBranchLabel0: Color(0xff2c2c2c),
    gitBranchLabel1: Color(0xffd3d3d3),
    gitBranchLabel2: Color(0xffd3d3d3),
    gitBranchLabel3: Color(0xff2c2c2c),
    gitBranchLabel4: Color(0xffd3d3d3),
    gitBranchLabel5: Color(0xffd3d3d3),
    gitBranchLabel6: Color(0xffd3d3d3),
    gitBranchLabel7: Color(0xffd3d3d3),
    commitLabelColor: Color(0xffb8b6b6),
    commitLabelBackground: Color(0xff474949),
    tagLabelColor: Color(0xffe0dfdf),
    tagLabelBackground: Color(0xff1f2020),
    tagLabelBorder: Color(0xffcccccc),
    actorBkg: Color(0xff1f2020),
    actorBorder: Color(0xffcccccc),
    actorTextColor: Color(0xffd3d3d3),
    actorLineColor: Color(0xffcccccc),
    signalColor: Color(0xffd3d3d3),
    signalTextColor: Color(0xffd3d3d3),
    labelBoxBkgColor: Color(0xff1f2020),
    labelBoxBorderColor: Color(0xffcccccc),
    labelTextColor: Color(0xffd3d3d3),
    loopTextColor: Color(0xffd3d3d3),
    noteBkgColor: Color(0xff474949),
    noteBorderColor: Color(0xff2f2f2f),
    noteTextColor: Color(0xffb8b6b6),
    activationBkgColor: Color(0xff474949),
    activationBorderColor: Color(0xffcccccc),
    fillType0: Color(0xff1f2020),
    fillType1: Color(0xff474949),
    fillType2: Color(0xff1f1f20),
    fillType3: Color(0xff474749),
    fillType4: Color(0xff1f201f),
    fillType5: Color(0xff474947),
    fillType6: Color(0xff201f20),
    fillType7: Color(0xff494749),
    quadrant1Fill: Color(0xff1f2020),
    quadrant2Fill: Color(0xff242525),
    quadrant3Fill: Color(0xff292a2a),
    quadrant4Fill: Color(0xff2e2f2f),
    quadrant1TextFill: Color(0xffe0dfdf),
    quadrant2TextFill: Color(0xffdbdada),
    quadrant3TextFill: Color(0xffd6d5d5),
    quadrant4TextFill: Color(0xffd1d0d0),
    quadrantPointFill: Color(0xff383a3a),
    quadrantPointTextFill: Color(0xffe0dfdf),
    quadrantXAxisTextFill: Color(0xffe0dfdf),
    quadrantYAxisTextFill: Color(0xffe0dfdf),
    quadrantInternalBorderStrokeFill: Color(0xffcccccc),
    quadrantExternalBorderStrokeFill: Color(0xffcccccc),
    quadrantTitleFill: Color(0xffe0dfdf),
    attributeBackgroundColorOdd: Color(0xff525252),
    attributeBackgroundColorEven: Color(0xff383838),
    rowOdd: Color(0xff2c2d2d),
    rowEven: Color(0xff060606),
    venn1: Color(0xff6a6e6e),
    venn2: Color(0xffa40000),
    venn3: Color(0xffcc2a91),
    venn4: Color(0xff87a1a9),
    venn5: Color(0xffbf7344),
    venn6: Color(0xffeb2626),
    venn7: Color(0xffb800e1),
    venn8: Color(0xfffeab35),
    vennTitleTextColor: Color(0xfff9fffe),
    vennSetTextColor: Color(0xffcccccc),
    requirementBackground: Color(0xff1f2020),
    requirementBorderColor: Color(0xffcccccc),
    requirementTextColor: Color(0xffe0dfdf),
    relationColor: Color(0xffd3d3d3),
    relationLabelBackground: Color(0xff474949),
    relationLabelColor: Color(0xffd3d3d3),
  );

  /// Values from upstream theme-forest.js.
  static const MermaidTheme forestTheme = MermaidTheme(
    xyChartPlotColorPalette: _forestXyChartPlotColorPalette,
    background: Color(0xffffffff),
    primaryColor: Color(0xffcde498),
    primaryTextColor: Color(0xff333333),
    primaryBorderColor: Color(0xff13540c),
    secondaryColor: Color(0xffcdffb2),
    lineColor: Color(0xff008000),
    arrowheadColor: Color(0xff008000),
    textColor: Color(0xff333333),
    nodeBorder: Color(0xff13540c),
    mainBkg: Color(0xffcde498),
    clusterBkg: Color(0xffcdffb2),
    clusterBorder: Color(0xff6eaa49),
    titleColor: Color(0xff333333),
    edgeLabelBackground: Color(0xcce8e8e8),
    fontFamily: '"trebuchet ms", verdana, arial, sans-serif',
    fontSize: 16,
    cScale0: Color(0xffb9d970),
    cScale1: Color(0xffacff7f),
    cScale2: Color(0xffcde498),
    cScale3: Color(0xff84d970),
    cScale4: Color(0xff70d990),
    cScale5: Color(0xff70d9c5),
    cScale6: Color(0xff70b9d9),
    cScale7: Color(0xff7084d9),
    cScale8: Color(0xffc570d9),
    cScale9: Color(0xffd97084),
    cScale10: Color(0xffd99070),
    cScale11: Color(0xffd9c570),
    cScaleInv0: Color(0xff9070d9),
    cScaleInv1: Color(0xffd27fff),
    cScaleInv2: Color(0xffaf98e4),
    cScaleInv3: Color(0xffc570d9),
    cScaleInv4: Color(0xffd970b9),
    cScaleInv5: Color(0xffd97084),
    cScaleInv6: Color(0xffd99070),
    cScaleInv7: Color(0xffd9c570),
    cScaleInv8: Color(0xff84d970),
    cScaleInv9: Color(0xff70d9c5),
    cScaleInv10: Color(0xff70b9d9),
    cScaleInv11: Color(0xff7084d9),
    cScaleLabel0: Color(0xff000000),
    cScaleLabel1: Color(0xff000000),
    cScaleLabel2: Color(0xff000000),
    cScaleLabel3: Color(0xff000000),
    cScaleLabel4: Color(0xff000000),
    cScaleLabel5: Color(0xff000000),
    cScaleLabel6: Color(0xff000000),
    cScaleLabel7: Color(0xff000000),
    cScaleLabel8: Color(0xff000000),
    cScaleLabel9: Color(0xff000000),
    cScaleLabel10: Color(0xff000000),
    cScaleLabel11: Color(0xff000000),
    cScalePeer0: Color(0xff7ca02a),
    cScalePeer1: Color(0xff47cb00),
    cScalePeer2: Color(0xff8cb42f),
    cScalePeer3: Color(0xff41a02a),
    cScalePeer4: Color(0xff2aa04d),
    cScalePeer5: Color(0xff2aa088),
    cScalePeer6: Color(0xff2a7ca0),
    cScalePeer7: Color(0xff2a41a0),
    cScalePeer8: Color(0xff882aa0),
    cScalePeer9: Color(0xffa02a41),
    cScalePeer10: Color(0xffa04d2a),
    cScalePeer11: Color(0xffa0882a),
    pie1: Color(0xffcde498),
    pie2: Color(0xffcdffb2),
    pie3: Color(0xffe1efc0),
    pie4: Color(0xff8cb42f),
    pie5: Color(0xff6aff19),
    pie6: Color(0xff33b42f),
    pie7: Color(0xff70d990),
    pie8: Color(0xffd99070),
    pie9: Color(0xff98cde4),
    pie10: Color(0xff1a6330),
    pie11: Color(0xff63301a),
    pie12: Color(0xff1a4d63),
    pieStrokeColor: Color(0xff000000),
    pieOuterStrokeColor: Color(0xff000000),
    pieSectionTextColor: Color(0xff000000),
    pieLegendTextColor: Color(0xff000000),
    pieTitleTextColor: Color(0xff000000),
    git0: Color(0xff9bc834),
    git1: Color(0xff7aff32),
    git2: Color(0xffb0d45b),
    git3: Color(0xffc8ab34),
    git4: Color(0xffc86134),
    git5: Color(0xffc83452),
    git6: Color(0xff34c861),
    git7: Color(0xff349bc8),
    gitInv0: Color(0xff6437cb),
    gitInv1: Color(0xff8500cd),
    gitInv2: Color(0xff4f2ba4),
    gitInv3: Color(0xff3754cb),
    gitInv4: Color(0xff379ecb),
    gitInv5: Color(0xff37cbad),
    gitInv6: Color(0xffcb379e),
    gitInv7: Color(0xffcb6437),
    gitBranchLabel0: Color(0xffffffff),
    gitBranchLabel1: Color(0xff000000),
    gitBranchLabel2: Color(0xff000000),
    gitBranchLabel3: Color(0xffffffff),
    gitBranchLabel4: Color(0xff000000),
    gitBranchLabel5: Color(0xff000000),
    gitBranchLabel6: Color(0xff000000),
    gitBranchLabel7: Color(0xff000000),
    commitLabelColor: Color(0xff32004d),
    commitLabelBackground: Color(0xffcdffb2),
    tagLabelColor: Color(0xff321b67),
    tagLabelBackground: Color(0xffcde498),
    tagLabelBorder: Color(0xffabb594),
    actorBkg: Color(0xffcde498),
    actorBorder: Color(0xffa6cf47),
    actorTextColor: Color(0xff000000),
    actorLineColor: Color(0xffa6cf47),
    signalColor: Color(0xff333333),
    signalTextColor: Color(0xff333333),
    labelBoxBkgColor: Color(0xffcde498),
    labelBoxBorderColor: Color(0xff326932),
    labelTextColor: Color(0xff000000),
    loopTextColor: Color(0xff000000),
    noteBkgColor: Color(0xfffff5ad),
    noteBorderColor: Color(0xff6eaa49),
    noteTextColor: Color(0xff000000),
    activationBkgColor: Color(0xfff4f4f4),
    activationBorderColor: Color(0xff666666),
    fillType0: Color(0xffcde498),
    fillType1: Color(0xffcdffb2),
    fillType2: Color(0xff98e4b4),
    fillType3: Color(0xffb2ffe9),
    fillType4: Color(0xffe4aa98),
    fillType5: Color(0xffffdfb2),
    fillType6: Color(0xff98c3e4),
    fillType7: Color(0xffb2c3ff),
    quadrant1Fill: Color(0xffcde498),
    quadrant2Fill: Color(0xffd2e99d),
    quadrant3Fill: Color(0xffd7eea2),
    quadrant4Fill: Color(0xffdcf3a7),
    quadrant1TextFill: Color(0xff321b67),
    quadrant2TextFill: Color(0xff2d1662),
    quadrant3TextFill: Color(0xff28115d),
    quadrant4TextFill: Color(0xff230c58),
    quadrantPointFill: Color(0xffb9d970),
    quadrantPointTextFill: Color(0xff321b67),
    quadrantXAxisTextFill: Color(0xff321b67),
    quadrantYAxisTextFill: Color(0xff321b67),
    quadrantInternalBorderStrokeFill: Color(0xffabb594),
    quadrantExternalBorderStrokeFill: Color(0xffabb594),
    quadrantTitleFill: Color(0xff321b67),
    attributeBackgroundColorOdd: Color(0xffffffff),
    attributeBackgroundColorEven: Color(0xfff2f2f2),
    rowOdd: Color(0xffffffff),
    rowEven: Color(0xfff4f9e9),
    venn1: Color(0xff8cb42f),
    venn2: Color(0xff6aff19),
    venn3: Color(0xffa6cf47),
    venn4: Color(0xff2fb457),
    venn5: Color(0xffb4572f),
    venn6: Color(0xff19ffae),
    venn7: Color(0xff2f8cb4),
    venn8: Color(0xff196aff),
    vennTitleTextColor: Color(0xff333333),
    vennSetTextColor: Color(0xff000000),
    requirementBackground: Color(0xffcde498),
    requirementBorderColor: Color(0xffabb594),
    requirementTextColor: Color(0xff321b67),
    relationColor: Color(0xff000000),
    relationLabelBackground: Color(0xffe8e8e8),
    relationLabelColor: Color(0xff000000),
  );

  /// Values from upstream theme-neutral.js.
  static const MermaidTheme neutralTheme = MermaidTheme(
    background: Color(0xffffffff),
    primaryColor: Color(0xffeeeeee),
    primaryTextColor: Color(0xff333333),
    primaryBorderColor: Color(0xff999999),
    secondaryColor: Color(0xfff4f4f4),
    lineColor: Color(0xff666666),
    arrowheadColor: Color(0xff333333),
    textColor: Color(0xff333333),
    nodeBorder: Color(0xff999999),
    mainBkg: Color(0xffeeeeee),
    clusterBkg: Color(0xfff6f6f6),
    clusterBorder: Color(0xffaaaaaa),
    titleColor: Color(0xff333333),
    edgeLabelBackground: Color(0xccffffff),
    fontFamily: '"trebuchet ms", verdana, arial, sans-serif',
    fontSize: 16,
    cScale0: Color(0xff555555),
    cScale1: Color(0xfff4f4f4),
    cScale2: Color(0xff555555),
    cScale3: Color(0xffbbbbbb),
    cScale4: Color(0xff777777),
    cScale5: Color(0xff999999),
    cScale6: Color(0xffdddddd),
    cScale7: Color(0xffffffff),
    cScale8: Color(0xffdddddd),
    cScale9: Color(0xffbbbbbb),
    cScale10: Color(0xff999999),
    cScale11: Color(0xff777777),
    cScaleInv0: Color(0xffaaaaaa),
    cScaleInv1: Color(0xff0b0b0b),
    cScaleInv2: Color(0xffaaaaaa),
    cScaleInv3: Color(0xff444444),
    cScaleInv4: Color(0xff888888),
    cScaleInv5: Color(0xff666666),
    cScaleInv6: Color(0xff222222),
    cScaleInv7: Color(0xff000000),
    cScaleInv8: Color(0xff222222),
    cScaleInv9: Color(0xff444444),
    cScaleInv10: Color(0xff666666),
    cScaleInv11: Color(0xff888888),
    cScaleLabel0: Color(0xfff4f4f4),
    cScaleLabel1: Color(0xff333333),
    cScaleLabel2: Color(0xfff4f4f4),
    cScaleLabel3: Color(0xff333333),
    cScaleLabel4: Color(0xff333333),
    cScaleLabel5: Color(0xff333333),
    cScaleLabel6: Color(0xff333333),
    cScaleLabel7: Color(0xff333333),
    cScaleLabel8: Color(0xff333333),
    cScaleLabel9: Color(0xff333333),
    cScaleLabel10: Color(0xff333333),
    cScaleLabel11: Color(0xff333333),
    cScalePeer0: Color(0xff3b3b3b),
    cScalePeer1: Color(0xffdadada),
    cScalePeer2: Color(0xff3b3b3b),
    cScalePeer3: Color(0xffa1a1a1),
    cScalePeer4: Color(0xff5e5e5e),
    cScalePeer5: Color(0xff7f7f7f),
    cScalePeer6: Color(0xffc4c4c4),
    cScalePeer7: Color(0xffe5e5e5),
    cScalePeer8: Color(0xffc4c4c4),
    cScalePeer9: Color(0xffa1a1a1),
    cScalePeer10: Color(0xff7f7f7f),
    cScalePeer11: Color(0xff5e5e5e),
    pie1: Color(0xfff4f4f4),
    pie2: Color(0xff555555),
    pie3: Color(0xffbbbbbb),
    pie4: Color(0xff777777),
    pie5: Color(0xff999999),
    pie6: Color(0xffdddddd),
    pie7: Color(0xffffffff),
    pie8: Color(0xffdddddd),
    pie9: Color(0xffbbbbbb),
    pie10: Color(0xff999999),
    pie11: Color(0xff777777),
    pie12: Color(0xff555555),
    pieStrokeColor: Color(0xff000000),
    pieOuterStrokeColor: Color(0xff000000),
    pieSectionTextColor: Color(0xff000000),
    pieLegendTextColor: Color(0xff333333),
    pieTitleTextColor: Color(0xff333333),
    git0: Color(0xffb4b4b4),
    git1: Color(0xff555555),
    git2: Color(0xffbbbbbb),
    git3: Color(0xff777777),
    git4: Color(0xff999999),
    git5: Color(0xffdddddd),
    git6: Color(0xffffffff),
    git7: Color(0xffdddddd),
    gitInv0: Color(0xff4b4b4b),
    gitInv1: Color(0xffaaaaaa),
    gitInv2: Color(0xff444444),
    gitInv3: Color(0xff888888),
    gitInv4: Color(0xff666666),
    gitInv5: Color(0xff222222),
    gitInv6: Color(0xff000000),
    gitInv7: Color(0xff222222),
    gitBranchLabel0: Color(0xff333333),
    gitBranchLabel1: Color(0xffffffff),
    gitBranchLabel2: Color(0xff333333),
    gitBranchLabel3: Color(0xffffffff),
    gitBranchLabel4: Color(0xff333333),
    gitBranchLabel5: Color(0xff333333),
    gitBranchLabel6: Color(0xff333333),
    gitBranchLabel7: Color(0xff333333),
    commitLabelColor: Color(0xff030303),
    commitLabelBackground: Color(0xfffcfcfc),
    tagLabelColor: Color(0xff111111),
    tagLabelBackground: Color(0xffeeeeee),
    tagLabelBorder: Color(0xffd4d4d4),
    actorBkg: Color(0xffeeeeee),
    actorBorder: Color(0xffd4d4d4),
    actorTextColor: Color(0xff333333),
    actorLineColor: Color(0xffd4d4d4),
    signalColor: Color(0xff333333),
    signalTextColor: Color(0xff333333),
    labelBoxBkgColor: Color(0xffeeeeee),
    labelBoxBorderColor: Color(0xffd4d4d4),
    labelTextColor: Color(0xff333333),
    loopTextColor: Color(0xff333333),
    noteBkgColor: Color(0xff666666),
    noteBorderColor: Color(0xff999999),
    noteTextColor: Color(0xffffffff),
    activationBkgColor: Color(0xfff4f4f4),
    activationBorderColor: Color(0xff666666),
    fillType0: Color(0xffeeeeee),
    fillType1: Color(0xfffcfcfc),
    fillType2: Color(0xffeeeeee),
    fillType3: Color(0xfffcfcfc),
    fillType4: Color(0xffeeeeee),
    fillType5: Color(0xfffcfcfc),
    fillType6: Color(0xffeeeeee),
    fillType7: Color(0xfffcfcfc),
    quadrant1Fill: Color(0xffeeeeee),
    quadrant2Fill: Color(0xfff3f3f3),
    quadrant3Fill: Color(0xfff8f8f8),
    quadrant4Fill: Color(0xfffdfdfd),
    quadrant1TextFill: Color(0xff111111),
    quadrant2TextFill: Color(0xff0c0c0c),
    quadrant3TextFill: Color(0xff070707),
    quadrant4TextFill: Color(0xff020202),
    quadrantPointFill: Color(0xffd4d4d4),
    quadrantPointTextFill: Color(0xff111111),
    quadrantXAxisTextFill: Color(0xff111111),
    quadrantYAxisTextFill: Color(0xff111111),
    quadrantInternalBorderStrokeFill: Color(0xffd4d4d4),
    quadrantExternalBorderStrokeFill: Color(0xffd4d4d4),
    quadrantTitleFill: Color(0xff111111),
    attributeBackgroundColorOdd: Color(0xffffffff),
    attributeBackgroundColorEven: Color(0xfff2f2f2),
    rowOdd: Color(0xffffffff),
    rowEven: Color(0xfff4f4f4),
    venn1: Color(0xff555555),
    venn2: Color(0xfff4f4f4),
    venn3: Color(0xff555555),
    venn4: Color(0xffbbbbbb),
    venn5: Color(0xff777777),
    venn6: Color(0xff999999),
    venn7: Color(0xffdddddd),
    venn8: Color(0xffffffff),
    vennTitleTextColor: Color(0xff333333),
    vennSetTextColor: Color(0xff000000),
    requirementBackground: Color(0xffeeeeee),
    requirementBorderColor: Color(0xffd4d4d4),
    requirementTextColor: Color(0xff111111),
    relationColor: Color(0xff666666),
    relationLabelBackground: Color(0xffffffff),
    relationLabelColor: Color(0xff333333),
  );

  /// Builds a theme from a mermaid.js-style `themeVariables` map.
  ///
  /// mermaid.js lets a caller override any color by name. The port
  /// exposes the same vocabulary, so a configuration written for
  /// mermaid.js can be pasted here unchanged: every palette entry has a
  /// variable name, and an unknown name is ignored rather than fatal —
  /// the same forgiving behavior mermaid.js has.
  ///
  /// Values are [Color]s. The three palette entries take a
  /// `List<Color>` instead: `xyChartPlotColorPalette`,
  /// `ganttSectionBkgColors`, `journeyActorColors` and
  /// `sankeyColorPalette`.
  ///
  /// ```dart
  /// final theme = MermaidTheme.withVariables({
  ///   'primaryColor': const Color(0xffeeeeee),
  ///   'lineColor': const Color(0xff333333),
  /// });
  /// ```
  static MermaidTheme withVariables(
    Map<String, Object> variables, {
    MermaidTheme base = defaultTheme,
  }) {
    // mermaid.js nests a few variables under a diagram prefix
    // (`gantt.taskBkgColor`); the port names them flat
    // (`ganttTaskBkgColor`). Both spellings resolve to the same token,
    // and the flat spelling wins when both are given.
    final resolved = <String, Object>{};
    for (final entry in variables.entries) {
      final alias = _variableAliases[entry.key];
      if (alias != null) resolved[alias] = entry.value;
    }
    for (final entry in variables.entries) {
      if (_variableAliases.containsKey(entry.key)) continue;
      resolved[entry.key] = entry.value;
    }
    Color? color(String name) {
      final value = resolved[name];
      return value is Color ? value : null;
    }

    List<Color>? colors(String name) {
      final value = resolved[name];
      return value is List<Color> ? value : null;
    }

    return base.copyWith(
      background: color('background'),
      primaryColor: color('primaryColor'),
      primaryTextColor: color('primaryTextColor'),
      primaryBorderColor: color('primaryBorderColor'),
      secondaryColor: color('secondaryColor'),
      lineColor: color('lineColor'),
      arrowheadColor: color('arrowheadColor'),
      textColor: color('textColor'),
      nodeBorder: color('nodeBorder'),
      mainBkg: color('mainBkg'),
      clusterBkg: color('clusterBkg'),
      clusterBorder: color('clusterBorder'),
      titleColor: color('titleColor'),
      edgeLabelBackground: color('edgeLabelBackground'),
      cScale0: color('cScale0'),
      cScale1: color('cScale1'),
      cScale2: color('cScale2'),
      cScale3: color('cScale3'),
      cScale4: color('cScale4'),
      cScale5: color('cScale5'),
      cScale6: color('cScale6'),
      cScale7: color('cScale7'),
      cScale8: color('cScale8'),
      cScale9: color('cScale9'),
      cScale10: color('cScale10'),
      cScale11: color('cScale11'),
      cScaleInv0: color('cScaleInv0'),
      cScaleInv1: color('cScaleInv1'),
      cScaleInv2: color('cScaleInv2'),
      cScaleInv3: color('cScaleInv3'),
      cScaleInv4: color('cScaleInv4'),
      cScaleInv5: color('cScaleInv5'),
      cScaleInv6: color('cScaleInv6'),
      cScaleInv7: color('cScaleInv7'),
      cScaleInv8: color('cScaleInv8'),
      cScaleInv9: color('cScaleInv9'),
      cScaleInv10: color('cScaleInv10'),
      cScaleInv11: color('cScaleInv11'),
      cScaleLabel0: color('cScaleLabel0'),
      cScaleLabel1: color('cScaleLabel1'),
      cScaleLabel2: color('cScaleLabel2'),
      cScaleLabel3: color('cScaleLabel3'),
      cScaleLabel4: color('cScaleLabel4'),
      cScaleLabel5: color('cScaleLabel5'),
      cScaleLabel6: color('cScaleLabel6'),
      cScaleLabel7: color('cScaleLabel7'),
      cScaleLabel8: color('cScaleLabel8'),
      cScaleLabel9: color('cScaleLabel9'),
      cScaleLabel10: color('cScaleLabel10'),
      cScaleLabel11: color('cScaleLabel11'),
      cScalePeer0: color('cScalePeer0'),
      cScalePeer1: color('cScalePeer1'),
      cScalePeer2: color('cScalePeer2'),
      cScalePeer3: color('cScalePeer3'),
      cScalePeer4: color('cScalePeer4'),
      cScalePeer5: color('cScalePeer5'),
      cScalePeer6: color('cScalePeer6'),
      cScalePeer7: color('cScalePeer7'),
      cScalePeer8: color('cScalePeer8'),
      cScalePeer9: color('cScalePeer9'),
      cScalePeer10: color('cScalePeer10'),
      cScalePeer11: color('cScalePeer11'),
      pie1: color('pie1'),
      pie2: color('pie2'),
      pie3: color('pie3'),
      pie4: color('pie4'),
      pie5: color('pie5'),
      pie6: color('pie6'),
      pie7: color('pie7'),
      pie8: color('pie8'),
      pie9: color('pie9'),
      pie10: color('pie10'),
      pie11: color('pie11'),
      pie12: color('pie12'),
      pieStrokeColor: color('pieStrokeColor'),
      pieOuterStrokeColor: color('pieOuterStrokeColor'),
      pieSectionTextColor: color('pieSectionTextColor'),
      pieLegendTextColor: color('pieLegendTextColor'),
      pieTitleTextColor: color('pieTitleTextColor'),
      git0: color('git0'),
      git1: color('git1'),
      git2: color('git2'),
      git3: color('git3'),
      git4: color('git4'),
      git5: color('git5'),
      git6: color('git6'),
      git7: color('git7'),
      gitInv0: color('gitInv0'),
      gitInv1: color('gitInv1'),
      gitInv2: color('gitInv2'),
      gitInv3: color('gitInv3'),
      gitInv4: color('gitInv4'),
      gitInv5: color('gitInv5'),
      gitInv6: color('gitInv6'),
      gitInv7: color('gitInv7'),
      gitBranchLabel0: color('gitBranchLabel0'),
      gitBranchLabel1: color('gitBranchLabel1'),
      gitBranchLabel2: color('gitBranchLabel2'),
      gitBranchLabel3: color('gitBranchLabel3'),
      gitBranchLabel4: color('gitBranchLabel4'),
      gitBranchLabel5: color('gitBranchLabel5'),
      gitBranchLabel6: color('gitBranchLabel6'),
      gitBranchLabel7: color('gitBranchLabel7'),
      commitLabelColor: color('commitLabelColor'),
      commitLabelBackground: color('commitLabelBackground'),
      tagLabelColor: color('tagLabelColor'),
      tagLabelBackground: color('tagLabelBackground'),
      tagLabelBorder: color('tagLabelBorder'),
      actorBkg: color('actorBkg'),
      actorBorder: color('actorBorder'),
      actorTextColor: color('actorTextColor'),
      actorLineColor: color('actorLineColor'),
      signalColor: color('signalColor'),
      signalTextColor: color('signalTextColor'),
      labelBoxBkgColor: color('labelBoxBkgColor'),
      labelBoxBorderColor: color('labelBoxBorderColor'),
      labelTextColor: color('labelTextColor'),
      loopTextColor: color('loopTextColor'),
      noteBkgColor: color('noteBkgColor'),
      noteBorderColor: color('noteBorderColor'),
      noteTextColor: color('noteTextColor'),
      activationBkgColor: color('activationBkgColor'),
      activationBorderColor: color('activationBorderColor'),
      fillType0: color('fillType0'),
      fillType1: color('fillType1'),
      fillType2: color('fillType2'),
      fillType3: color('fillType3'),
      fillType4: color('fillType4'),
      fillType5: color('fillType5'),
      fillType6: color('fillType6'),
      fillType7: color('fillType7'),
      quadrant1Fill: color('quadrant1Fill'),
      quadrant2Fill: color('quadrant2Fill'),
      quadrant3Fill: color('quadrant3Fill'),
      quadrant4Fill: color('quadrant4Fill'),
      quadrant1TextFill: color('quadrant1TextFill'),
      quadrant2TextFill: color('quadrant2TextFill'),
      quadrant3TextFill: color('quadrant3TextFill'),
      quadrant4TextFill: color('quadrant4TextFill'),
      quadrantPointFill: color('quadrantPointFill'),
      quadrantPointTextFill: color('quadrantPointTextFill'),
      quadrantXAxisTextFill: color('quadrantXAxisTextFill'),
      quadrantYAxisTextFill: color('quadrantYAxisTextFill'),
      quadrantInternalBorderStrokeFill:
          color('quadrantInternalBorderStrokeFill'),
      quadrantExternalBorderStrokeFill:
          color('quadrantExternalBorderStrokeFill'),
      quadrantTitleFill: color('quadrantTitleFill'),
      attributeBackgroundColorOdd: color('attributeBackgroundColorOdd'),
      attributeBackgroundColorEven: color('attributeBackgroundColorEven'),
      rowOdd: color('rowOdd'),
      rowEven: color('rowEven'),
      venn1: color('venn1'),
      venn2: color('venn2'),
      venn3: color('venn3'),
      venn4: color('venn4'),
      venn5: color('venn5'),
      venn6: color('venn6'),
      venn7: color('venn7'),
      venn8: color('venn8'),
      vennTitleTextColor: color('vennTitleTextColor'),
      vennSetTextColor: color('vennSetTextColor'),
      requirementBackground: color('requirementBackground'),
      requirementBorderColor: color('requirementBorderColor'),
      requirementTextColor: color('requirementTextColor'),
      relationColor: color('relationColor'),
      relationLabelBackground: color('relationLabelBackground'),
      relationLabelColor: color('relationLabelColor'),
      canvasColor: color('canvasColor'),
      textOnDarkFill: color('textOnDarkFill'),
      textOnLightFill: color('textOnLightFill'),
      tertiaryColor: color('tertiaryColor'),
      ganttTaskBkgColor: color('ganttTaskBkgColor'),
      ganttTaskBorderColor: color('ganttTaskBorderColor'),
      ganttActiveTaskBkgColor: color('ganttActiveTaskBkgColor'),
      ganttActiveTaskBorderColor: color('ganttActiveTaskBorderColor'),
      ganttDoneTaskBkgColor: color('ganttDoneTaskBkgColor'),
      ganttDoneTaskBorderColor: color('ganttDoneTaskBorderColor'),
      ganttCritBkgColor: color('ganttCritBkgColor'),
      ganttCritBorderColor: color('ganttCritBorderColor'),
      ganttTaskTextColor: color('ganttTaskTextColor'),
      ganttActiveTaskTextColor: color('ganttActiveTaskTextColor'),
      ganttDoneTaskTextColor: color('ganttDoneTaskTextColor'),
      ganttCritTaskTextColor: color('ganttCritTaskTextColor'),
      ganttTaskTextOutsideColor: color('ganttTaskTextOutsideColor'),
      ganttExcludeBkgColor: color('ganttExcludeBkgColor'),
      ganttGridColor: color('ganttGridColor'),
      ganttTodayLineColor: color('ganttTodayLineColor'),
      sequenceAltFrameColor: color('sequenceAltFrameColor'),
      gitMergeInnerColor: color('gitMergeInnerColor'),
      railroadSpecialFill: color('railroadSpecialFill'),
      railroadSpecialStroke: color('railroadSpecialStroke'),
      radarGraticuleColor: color('radarGraticuleColor'),
      packetBlockFill: color('packetBlockFill'),
      packetBlockBorder: color('packetBlockBorder'),
      packetTextColor: color('packetTextColor'),
      kanbanPriorityVeryHigh: color('kanbanPriorityVeryHigh'),
      kanbanPriorityHigh: color('kanbanPriorityHigh'),
      kanbanPriorityLow: color('kanbanPriorityLow'),
      kanbanPriorityVeryLow: color('kanbanPriorityVeryLow'),
      c4PersonFill: color('c4PersonFill'),
      c4PersonBorder: color('c4PersonBorder'),
      c4PersonExtFill: color('c4PersonExtFill'),
      c4PersonExtBorder: color('c4PersonExtBorder'),
      c4SystemFill: color('c4SystemFill'),
      c4SystemBorder: color('c4SystemBorder'),
      c4SystemExtFill: color('c4SystemExtFill'),
      c4SystemExtBorder: color('c4SystemExtBorder'),
      c4QueueFill: color('c4QueueFill'),
      c4QueueBorder: color('c4QueueBorder'),
      c4ContainerFill: color('c4ContainerFill'),
      c4ContainerBorder: color('c4ContainerBorder'),
      c4ComponentFill: color('c4ComponentFill'),
      c4ComponentBorder: color('c4ComponentBorder'),
      c4ExternalPersonFill: color('c4ExternalPersonFill'),
      c4ExternalPersonBorder: color('c4ExternalPersonBorder'),
      c4ExternalSystemFill: color('c4ExternalSystemFill'),
      c4ExternalSystemBorder: color('c4ExternalSystemBorder'),
      c4ExternalContainerFill: color('c4ExternalContainerFill'),
      c4ExternalContainerBorder: color('c4ExternalContainerBorder'),
      c4ExternalComponentFill: color('c4ExternalComponentFill'),
      c4ExternalComponentBorder: color('c4ExternalComponentBorder'),
      c4BoundaryColor: color('c4BoundaryColor'),
      c4TextColor: color('c4TextColor'),
      wardleyAxisColor: color('wardleyAxisColor'),
      wardleyAxisTextColor: color('wardleyAxisTextColor'),
      wardleyComponentFill: color('wardleyComponentFill'),
      wardleyComponentStroke: color('wardleyComponentStroke'),
      wardleyComponentLabelColor: color('wardleyComponentLabelColor'),
      wardleyLinkStroke: color('wardleyLinkStroke'),
      wardleyEvolutionStroke: color('wardleyEvolutionStroke'),
      wardleyAnnotationStroke: color('wardleyAnnotationStroke'),
      wardleyOutsourceFill: color('wardleyOutsourceFill'),
      wardleyBuyFill: color('wardleyBuyFill'),
      wardleyBuildFill: color('wardleyBuildFill'),
      emUiFill: color('emUiFill'),
      emUiStroke: color('emUiStroke'),
      emProcessorFill: color('emProcessorFill'),
      emProcessorStroke: color('emProcessorStroke'),
      emReadModelFill: color('emReadModelFill'),
      emReadModelStroke: color('emReadModelStroke'),
      emCommandFill: color('emCommandFill'),
      emCommandStroke: color('emCommandStroke'),
      emEventFill: color('emEventFill'),
      emEventStroke: color('emEventStroke'),
      emUnknownTypeFill: color('emUnknownTypeFill'),
      emSwimlaneBackgroundOdd: color('emSwimlaneBackgroundOdd'),
      emSwimlaneBackgroundStroke: color('emSwimlaneBackgroundStroke'),
      journeyFaceFill: color('journeyFaceFill'),
      journeyFaceBorder: color('journeyFaceBorder'),
      journeyFaceEyeColor: color('journeyFaceEyeColor'),
      cynefinComplexFill: color('cynefinComplexFill'),
      cynefinComplicatedFill: color('cynefinComplicatedFill'),
      cynefinClearFill: color('cynefinClearFill'),
      cynefinChaoticFill: color('cynefinChaoticFill'),
      cynefinConfusionFill: color('cynefinConfusionFill'),
      cynefinCliffColor: color('cynefinCliffColor'),
      xyChartPlotColorPalette: colors('xyChartPlotColorPalette'),
      ganttSectionBkgColors: colors('ganttSectionBkgColors'),
      journeyActorColors: colors('journeyActorColors'),
      sankeyColorPalette: colors('sankeyColorPalette'),
    );
  }

  /// mermaid.js variable names that differ from the port's flat spelling.
  static const Map<String, String> _variableAliases = <String, String>{
    'gantt.taskBkgColor': 'ganttTaskBkgColor',
    'gantt.taskBorderColor': 'ganttTaskBorderColor',
    'gantt.activeTaskBkgColor': 'ganttActiveTaskBkgColor',
    'gantt.activeTaskBorderColor': 'ganttActiveTaskBorderColor',
    'gantt.doneTaskBkgColor': 'ganttDoneTaskBkgColor',
    'gantt.doneTaskBorderColor': 'ganttDoneTaskBorderColor',
    'gantt.critBkgColor': 'ganttCritBkgColor',
    'gantt.critBorderColor': 'ganttCritBorderColor',
    'gantt.critTextColor': 'ganttCritTaskTextColor',
    'gantt.taskTextColor': 'ganttTaskTextColor',
    'gantt.taskTextDarkColor': 'ganttActiveTaskTextColor',
    'gantt.taskTextLightColor': 'ganttTaskTextColor',
    'gantt.taskTextOutsideColor': 'ganttTaskTextOutsideColor',
    'gantt.todayLineColor': 'ganttTodayLineColor',
    'gantt.gridColor': 'ganttGridColor',
    'gantt.excludeBkgColor': 'ganttExcludeBkgColor',
    'gantt.sectionBkgColor': 'ganttSectionBkgColors',
    'gantt.sectionBkgColor2': 'ganttSectionBkgColors',
    'gantt.altSectionBkgColor': 'ganttSectionBkgColors',
    'xyChart.plotColorPalette': 'xyChartPlotColorPalette',
  };

  /// Theme by its mermaid name; unknown names return [defaultTheme].
  static MermaidTheme named(String name) => switch (name) {
        'dark' => darkTheme,
        'forest' => forestTheme,
        'neutral' => neutralTheme,
        _ => defaultTheme,
      };
}
