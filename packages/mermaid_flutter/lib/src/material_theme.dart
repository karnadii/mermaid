import 'package:flutter/material.dart';
import 'package:mermaid_core/mermaid_core.dart' as core;

/// Creates complete [core.MermaidTheme] values from Material theme roles.
///
/// The mapping uses container roles for diagram fills, matching `on*` roles
/// for text, outline roles for borders, and `onSurfaceVariant` for edges.
/// [fromTheme] also maps `bodyMedium.fontFamily` and `bodyMedium.fontSize`.
/// Those text values affect measurement and can therefore change layout.
///
/// Every fill is paired with the `on*` role of that same fill, so text stays
/// readable in both brightness modes. Git lane labels therefore use the
/// on-roles of the lane colors (`git0` is `primary`, so `gitBranchLabel0` is
/// `onPrimary`). Pie slices all share one `pieSectionTextColor`, so that
/// palette stays on container and surface roles, which keep enough contrast
/// with `onSurface`, and wraps around rather than using the bright
/// primary, secondary, tertiary and error roles.
abstract final class MaterialMermaidTheme {
  /// Creates a Mermaid theme from [theme].
  static core.MermaidTheme fromTheme(ThemeData theme) =>
      fromColorScheme(theme.colorScheme, textTheme: theme.textTheme);

  /// Creates a Mermaid theme from [colorScheme] and optional [textTheme].
  ///
  /// When [textTheme] is omitted, the platform-independent Mermaid font
  /// defaults are retained. The categorical palette is derived from Material
  /// primary, secondary, tertiary, and error roles, with matching label
  /// colors, so it remains readable in both brightness modes.
  static core.MermaidTheme fromColorScheme(
    ColorScheme colorScheme, {
    TextTheme? textTheme,
  }) {
    final dark = colorScheme.brightness == Brightness.dark;
    final fallback =
        dark ? core.MermaidTheme.darkTheme : core.MermaidTheme.defaultTheme;
    final body = textTheme?.bodyMedium;
    final fills = <Color>[
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
      colorScheme.errorContainer,
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.error,
      colorScheme.surfaceContainerHighest,
      colorScheme.surfaceContainerHigh,
      colorScheme.surfaceContainer,
      colorScheme.surfaceContainerLow,
    ];
    final labels = <Color>[
      colorScheme.onPrimaryContainer,
      colorScheme.onSecondaryContainer,
      colorScheme.onTertiaryContainer,
      colorScheme.onErrorContainer,
      colorScheme.onPrimary,
      colorScheme.onSecondary,
      colorScheme.onTertiary,
      colorScheme.onError,
      colorScheme.onSurface,
      colorScheme.onSurface,
      colorScheme.onSurface,
      colorScheme.onSurface,
    ];
    final peers = <Color>[
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.error,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
      colorScheme.errorContainer,
      colorScheme.outline,
      colorScheme.outlineVariant,
      colorScheme.onSurfaceVariant,
      colorScheme.onSurface,
    ];

    // Git lanes are painted with [peers], which is [fills] rotated by four, so
    // their label colors are the on-roles rotated the same way.
    final gitLabels = <Color>[...labels.skip(4).take(4), ...labels.take(4)];
    // One text color has to work on every pie slice, so the pie palette stays
    // on container and surface roles and repeats instead of reaching for the
    // bright primary, secondary, tertiary and error roles.
    final pieFills = <Color>[
      ...fills.take(4),
      ...fills.skip(8),
      ...fills.take(4),
    ];

    core.Color c(Color value) => core.Color(value.toARGB32());

    // Base the mapping on the mode's named theme, so a token the mapping
    // does not touch keeps that mode's value (e.g. the dark
    // `c4BoundaryColor`) instead of silently falling back to the light
    // default.
    return fallback.copyWith(
      background: c(colorScheme.surface),
      primaryColor: c(colorScheme.primaryContainer),
      primaryTextColor: c(colorScheme.onPrimaryContainer),
      primaryBorderColor: c(colorScheme.primary),
      secondaryColor: c(colorScheme.secondaryContainer),
      lineColor: c(colorScheme.onSurfaceVariant),
      arrowheadColor: c(colorScheme.onSurfaceVariant),
      textColor: c(colorScheme.onSurface),
      nodeBorder: c(colorScheme.outline),
      mainBkg: c(colorScheme.primaryContainer),
      clusterBkg: c(colorScheme.surfaceContainerLow),
      clusterBorder: c(colorScheme.outlineVariant),
      titleColor: c(colorScheme.onSurface),
      edgeLabelBackground: c(colorScheme.surfaceContainerHigh),
      fontFamily: body?.fontFamily ?? fallback.fontFamily,
      fontSize: body?.fontSize ?? fallback.fontSize,
      cScale0: c(fills[0]),
      cScale1: c(fills[1]),
      cScale2: c(fills[2]),
      cScale3: c(fills[3]),
      cScale4: c(fills[4]),
      cScale5: c(fills[5]),
      cScale6: c(fills[6]),
      cScale7: c(fills[7]),
      cScale8: c(fills[8]),
      cScale9: c(fills[9]),
      cScale10: c(fills[10]),
      cScale11: c(fills[11]),
      cScaleInv0: c(labels[0]),
      cScaleInv1: c(labels[1]),
      cScaleInv2: c(labels[2]),
      cScaleInv3: c(labels[3]),
      cScaleInv4: c(labels[4]),
      cScaleInv5: c(labels[5]),
      cScaleInv6: c(labels[6]),
      cScaleInv7: c(labels[7]),
      cScaleInv8: c(labels[8]),
      cScaleInv9: c(labels[9]),
      cScaleInv10: c(labels[10]),
      cScaleInv11: c(labels[11]),
      cScaleLabel0: c(labels[0]),
      cScaleLabel1: c(labels[1]),
      cScaleLabel2: c(labels[2]),
      cScaleLabel3: c(labels[3]),
      cScaleLabel4: c(labels[4]),
      cScaleLabel5: c(labels[5]),
      cScaleLabel6: c(labels[6]),
      cScaleLabel7: c(labels[7]),
      cScaleLabel8: c(labels[8]),
      cScaleLabel9: c(labels[9]),
      cScaleLabel10: c(labels[10]),
      cScaleLabel11: c(labels[11]),
      cScalePeer0: c(peers[0]),
      cScalePeer1: c(peers[1]),
      cScalePeer2: c(peers[2]),
      cScalePeer3: c(peers[3]),
      cScalePeer4: c(peers[4]),
      cScalePeer5: c(peers[5]),
      cScalePeer6: c(peers[6]),
      cScalePeer7: c(peers[7]),
      cScalePeer8: c(peers[8]),
      cScalePeer9: c(peers[9]),
      cScalePeer10: c(peers[10]),
      cScalePeer11: c(peers[11]),
      pie1: c(pieFills[0]),
      pie2: c(pieFills[1]),
      pie3: c(pieFills[2]),
      pie4: c(pieFills[3]),
      pie5: c(pieFills[4]),
      pie6: c(pieFills[5]),
      pie7: c(pieFills[6]),
      pie8: c(pieFills[7]),
      pie9: c(pieFills[8]),
      pie10: c(pieFills[9]),
      pie11: c(pieFills[10]),
      pie12: c(pieFills[11]),
      pieStrokeColor: c(colorScheme.outline),
      pieOuterStrokeColor: c(colorScheme.outline),
      pieSectionTextColor: c(colorScheme.onSurface),
      pieLegendTextColor: c(colorScheme.onSurface),
      pieTitleTextColor: c(colorScheme.onSurface),
      git0: c(peers[0]),
      git1: c(peers[1]),
      git2: c(peers[2]),
      git3: c(peers[3]),
      git4: c(peers[4]),
      git5: c(peers[5]),
      git6: c(peers[6]),
      git7: c(peers[7]),
      gitInv0: c(gitLabels[0]),
      gitInv1: c(gitLabels[1]),
      gitInv2: c(gitLabels[2]),
      gitInv3: c(gitLabels[3]),
      gitInv4: c(gitLabels[4]),
      gitInv5: c(gitLabels[5]),
      gitInv6: c(gitLabels[6]),
      gitInv7: c(gitLabels[7]),
      gitBranchLabel0: c(gitLabels[0]),
      gitBranchLabel1: c(gitLabels[1]),
      gitBranchLabel2: c(gitLabels[2]),
      gitBranchLabel3: c(gitLabels[3]),
      gitBranchLabel4: c(gitLabels[4]),
      gitBranchLabel5: c(gitLabels[5]),
      gitBranchLabel6: c(gitLabels[6]),
      gitBranchLabel7: c(gitLabels[7]),
      commitLabelColor: c(colorScheme.onSecondaryContainer),
      commitLabelBackground: c(colorScheme.secondaryContainer),
      tagLabelColor: c(colorScheme.onTertiaryContainer),
      tagLabelBackground: c(colorScheme.tertiaryContainer),
      tagLabelBorder: c(colorScheme.tertiary),
      actorBkg: c(colorScheme.primaryContainer),
      actorBorder: c(colorScheme.primary),
      actorTextColor: c(colorScheme.onPrimaryContainer),
      actorLineColor: c(colorScheme.outline),
      signalColor: c(colorScheme.onSurfaceVariant),
      signalTextColor: c(colorScheme.onSurface),
      labelBoxBkgColor: c(colorScheme.secondaryContainer),
      labelBoxBorderColor: c(colorScheme.secondary),
      labelTextColor: c(colorScheme.onSecondaryContainer),
      loopTextColor: c(colorScheme.onSurface),
      noteBkgColor: c(colorScheme.tertiaryContainer),
      noteBorderColor: c(colorScheme.tertiary),
      noteTextColor: c(colorScheme.onTertiaryContainer),
      activationBkgColor: c(colorScheme.surfaceContainerHighest),
      activationBorderColor: c(colorScheme.outline),
      fillType0: c(fills[0]),
      fillType1: c(fills[1]),
      fillType2: c(fills[2]),
      fillType3: c(fills[3]),
      fillType4: c(fills[8]),
      fillType5: c(fills[9]),
      fillType6: c(fills[10]),
      fillType7: c(fills[11]),
      quadrant1Fill: c(fills[0]),
      quadrant2Fill: c(fills[1]),
      quadrant3Fill: c(fills[2]),
      quadrant4Fill: c(fills[8]),
      quadrant1TextFill: c(labels[0]),
      quadrant2TextFill: c(labels[1]),
      quadrant3TextFill: c(labels[2]),
      quadrant4TextFill: c(labels[8]),
      quadrantPointFill: c(colorScheme.primary),
      quadrantPointTextFill: c(colorScheme.onSurface),
      quadrantXAxisTextFill: c(colorScheme.onSurface),
      quadrantYAxisTextFill: c(colorScheme.onSurface),
      quadrantInternalBorderStrokeFill: c(colorScheme.outlineVariant),
      quadrantExternalBorderStrokeFill: c(colorScheme.outline),
      quadrantTitleFill: c(colorScheme.onSurface),
      attributeBackgroundColorOdd: c(colorScheme.surfaceContainerLowest),
      attributeBackgroundColorEven: c(colorScheme.surfaceContainerLow),
      rowOdd: c(colorScheme.surfaceContainerLowest),
      rowEven: c(colorScheme.surfaceContainerLow),
      venn1: c(fills[0]),
      venn2: c(fills[1]),
      venn3: c(fills[2]),
      venn4: c(fills[3]),
      venn5: c(fills[4]),
      venn6: c(fills[5]),
      venn7: c(fills[6]),
      venn8: c(fills[7]),
      vennTitleTextColor: c(colorScheme.onSurface),
      vennSetTextColor: c(colorScheme.onSurface),
      requirementBackground: c(colorScheme.primaryContainer),
      requirementBorderColor: c(colorScheme.primary),
      requirementTextColor: c(colorScheme.onPrimaryContainer),
      relationColor: c(colorScheme.onSurfaceVariant),
      relationLabelBackground: c(colorScheme.surfaceContainerHigh),
      relationLabelColor: c(colorScheme.onSurface),
      xyChartPlotColorPalette: fills.map(c).toList(growable: false),

      // --- Shared ---------------------------------------------------------
      //
      // `canvasColor` is the opaque surface a diagram is painted on. It
      // carries the knockout ink upstream draws with the theme background
      // (the git merge ring, the ER relationship leaf), which a transparent
      // background would erase.
      canvasColor: c(colorScheme.surface),
      // Text painted on a fill the host did not choose (a mindmap `classDef`
      // fill, a kanban card). Dark mode inverts which of the two is light.
      textOnDarkFill: c(dark ? colorScheme.onSurface : colorScheme.surface),
      textOnLightFill: c(dark ? colorScheme.surface : colorScheme.onSurface),
      tertiaryColor: c(colorScheme.tertiaryContainer),

      // --- Gantt ----------------------------------------------------------
      //
      // The chart chrome follows the scheme: a task bar is a primary
      // container, an active task a tertiary container, a completed task a
      // neutral surface. The critical state keeps the error role, because
      // "critical" is a status rather than a decoration.
      ganttTaskBkgColor: c(colorScheme.primaryContainer),
      ganttTaskBorderColor: c(colorScheme.primary),
      ganttActiveTaskBkgColor: c(colorScheme.tertiaryContainer),
      ganttActiveTaskBorderColor: c(colorScheme.tertiary),
      ganttDoneTaskBkgColor: c(colorScheme.surfaceContainerHighest),
      ganttDoneTaskBorderColor: c(colorScheme.outline),
      ganttCritBkgColor: c(colorScheme.errorContainer),
      ganttCritBorderColor: c(colorScheme.error),
      ganttTaskTextColor: c(colorScheme.onPrimaryContainer),
      ganttActiveTaskTextColor: c(colorScheme.onTertiaryContainer),
      ganttDoneTaskTextColor: c(colorScheme.onSurfaceVariant),
      ganttCritTaskTextColor: c(colorScheme.onErrorContainer),
      // A label that overflows its bar sits on the canvas, not on the bar.
      ganttTaskTextOutsideColor: c(colorScheme.onSurface),
      ganttExcludeBkgColor: c(colorScheme.surfaceContainerHigh),
      ganttGridColor: c(colorScheme.outlineVariant),
      ganttTodayLineColor: c(colorScheme.error),
      ganttSectionBkgColors: [
        c(colorScheme.surfaceContainerHighest),
        c(colorScheme.surfaceContainerHigh),
        c(colorScheme.surfaceContainerHighest),
        c(colorScheme.surfaceContainerHigh),
      ],

      // --- Sequence -------------------------------------------------------
      sequenceAltFrameColor: c(colorScheme.primaryContainer).withOpacity(0.12),

      // --- Git ------------------------------------------------------------
      gitMergeInnerColor: c(colorScheme.surface),

      // --- Railroad -------------------------------------------------------
      railroadSpecialFill: c(colorScheme.tertiaryContainer),
      railroadSpecialStroke: c(colorScheme.tertiary),

      // --- Radar ----------------------------------------------------------
      radarGraticuleColor: c(colorScheme.outlineVariant),

      // --- Packet ---------------------------------------------------------
      //
      // Upstream keeps the packet diagram theme-independent (a grey block
      // with black ink). The block stays a neutral surface so the diagram
      // still reads as a wire frame, but the ink follows the brightness.
      packetBlockFill: c(colorScheme.surfaceContainerHighest),
      packetBlockBorder: c(colorScheme.onSurfaceVariant),
      packetTextColor: c(colorScheme.onSurface),

      // --- Kanban ---------------------------------------------------------
      //
      // The priority bar is a status, so it takes the error, tertiary,
      // primary and secondary roles in that order.
      kanbanPriorityVeryHigh: c(colorScheme.error),
      kanbanPriorityHigh: c(colorScheme.tertiary),
      kanbanPriorityLow: c(colorScheme.primary),
      kanbanPriorityVeryLow: c(colorScheme.secondary),

      // --- Wardley --------------------------------------------------------
      wardleyAxisColor: c(colorScheme.onSurfaceVariant),
      wardleyAxisTextColor: c(colorScheme.onSurface),
      wardleyComponentFill: c(colorScheme.surfaceContainer),
      wardleyComponentStroke: c(colorScheme.outline),
      wardleyComponentLabelColor: c(colorScheme.onSurface),
      wardleyLinkStroke: c(colorScheme.onSurfaceVariant),
      // The evolution arrow marks risk, so it keeps the error role.
      wardleyEvolutionStroke: c(colorScheme.error),
      wardleyAnnotationStroke: c(colorScheme.onSurfaceVariant),
      wardleyOutsourceFill: c(colorScheme.surfaceContainerHighest),
      wardleyBuyFill: c(colorScheme.surfaceContainerHigh),
      wardleyBuildFill: c(colorScheme.surfaceContainer),

      // --- Event modeling -------------------------------------------------
      //
      // The entity fills keep their predefined pastel palette, because the
      // entity kind (UI, processor, read model, command, event) is the
      // diagram's data. Only the swimlane band follows the scheme.
      emSwimlaneBackgroundOdd: c(colorScheme.surfaceContainerLow),
      emSwimlaneBackgroundStroke: c(colorScheme.outlineVariant),
      // An entity whose kind the diagram does not know is a mistake in the
      // source, so it takes the error role.
      emUnknownTypeFill: c(colorScheme.error),

      // --- Journey --------------------------------------------------------
      //
      // The face keeps its cornsilk fill: it is a character, not a wash, so
      // it stays the same in both modes. The outline and eyes follow the
      // brightness.
      journeyFaceFill: c(const Color(0xfffff8dc)),
      journeyFaceBorder: c(colorScheme.outline),
      journeyFaceEyeColor: c(colorScheme.onSurfaceVariant),

      // --- Cynefin --------------------------------------------------------
      //
      // The domain fills stay predefined (the domain is the data), but the
      // cliff edge takes the error role so it stays visible in dark mode.
      cynefinCliffColor: c(colorScheme.error),
    );
  }
}
