import 'package:mermaid_core/mermaid_core.dart';
import 'package:test/test.dart';

/// Pins the diagram-specific palette entries of [MermaidTheme].
///
/// The default theme is upstream's theme-default.js, and the port's
/// parity with mermaid.js rests on those values. A change here is a
/// visible change to every default-theme diagram, so it has to be
/// deliberate. The named themes and the host mapping live in the same
/// file; this test only pins the constructor defaults.
void main() {
  group('diagram token defaults', () {
    test('canvasColor', () {
      expect(MermaidTheme.defaultTheme.canvasColor.value, 0xffffffff);
    });
    test('textOnDarkFill', () {
      expect(MermaidTheme.defaultTheme.textOnDarkFill.value, 0xffffffff);
    });
    test('textOnLightFill', () {
      expect(MermaidTheme.defaultTheme.textOnLightFill.value, 0xff333333);
    });
    test('tertiaryColor', () {
      expect(MermaidTheme.defaultTheme.tertiaryColor.value, 0xfff9ffec);
    });
    test('ganttTaskBkgColor', () {
      expect(MermaidTheme.defaultTheme.ganttTaskBkgColor.value, 0xff8a90dd);
    });
    test('ganttTaskBorderColor', () {
      expect(MermaidTheme.defaultTheme.ganttTaskBorderColor.value, 0xff534fbc);
    });
    test('ganttActiveTaskBkgColor', () {
      expect(
        MermaidTheme.defaultTheme.ganttActiveTaskBkgColor.value,
        0xffbfc7ff,
      );
    });
    test('ganttActiveTaskBorderColor', () {
      expect(
        MermaidTheme.defaultTheme.ganttActiveTaskBorderColor.value,
        0xff534fbc,
      );
    });
    test('ganttDoneTaskBkgColor', () {
      expect(MermaidTheme.defaultTheme.ganttDoneTaskBkgColor.value, 0xffd3d3d3);
    });
    test('ganttDoneTaskBorderColor', () {
      expect(
        MermaidTheme.defaultTheme.ganttDoneTaskBorderColor.value,
        0xff808080,
      );
    });
    test('ganttCritBkgColor', () {
      expect(MermaidTheme.defaultTheme.ganttCritBkgColor.value, 0xffff0000);
    });
    test('ganttCritBorderColor', () {
      expect(MermaidTheme.defaultTheme.ganttCritBorderColor.value, 0xffff8888);
    });
    test('ganttTaskTextColor', () {
      expect(MermaidTheme.defaultTheme.ganttTaskTextColor.value, 0xffffffff);
    });
    test('ganttActiveTaskTextColor', () {
      expect(
        MermaidTheme.defaultTheme.ganttActiveTaskTextColor.value,
        0xff000000,
      );
    });
    test('ganttDoneTaskTextColor', () {
      expect(
        MermaidTheme.defaultTheme.ganttDoneTaskTextColor.value,
        0xff000000,
      );
    });
    test('ganttCritTaskTextColor', () {
      expect(
        MermaidTheme.defaultTheme.ganttCritTaskTextColor.value,
        0xff000000,
      );
    });
    test('ganttTaskTextOutsideColor', () {
      expect(
        MermaidTheme.defaultTheme.ganttTaskTextOutsideColor.value,
        0xff000000,
      );
    });
    test('ganttExcludeBkgColor', () {
      expect(MermaidTheme.defaultTheme.ganttExcludeBkgColor.value, 0xffeeeeee);
    });
    test('ganttGridColor', () {
      expect(MermaidTheme.defaultTheme.ganttGridColor.value, 0xccd3d3d3);
    });
    test('ganttTodayLineColor', () {
      expect(MermaidTheme.defaultTheme.ganttTodayLineColor.value, 0xffff0000);
    });
    test('ganttSectionBkgColors', () {
      expect(
        MermaidTheme.defaultTheme.ganttSectionBkgColors.map((c) => c.value),
        [0x196666ff, 0x33ffffff, 0x33fff400, 0x33ffffff],
      );
    });
    test('sequenceAltFrameColor', () {
      expect(MermaidTheme.defaultTheme.sequenceAltFrameColor.value, 0x11888888);
    });
    test('gitMergeInnerColor', () {
      expect(MermaidTheme.defaultTheme.gitMergeInnerColor.value, 0xffffffff);
    });
    test('railroadSpecialFill', () {
      expect(MermaidTheme.defaultTheme.railroadSpecialFill.value, 0xfff0e0ff);
    });
    test('railroadSpecialStroke', () {
      expect(MermaidTheme.defaultTheme.railroadSpecialStroke.value, 0xff8800cc);
    });
    test('radarGraticuleColor', () {
      expect(MermaidTheme.defaultTheme.radarGraticuleColor.value, 0xffdedede);
    });
    test('packetBlockFill', () {
      expect(MermaidTheme.defaultTheme.packetBlockFill.value, 0xffefefef);
    });
    test('packetBlockBorder', () {
      expect(MermaidTheme.defaultTheme.packetBlockBorder.value, 0xff000000);
    });
    test('packetTextColor', () {
      expect(MermaidTheme.defaultTheme.packetTextColor.value, 0xff000000);
    });
    test('kanbanPriorityVeryHigh', () {
      expect(
        MermaidTheme.defaultTheme.kanbanPriorityVeryHigh.value,
        0xffff0000,
      );
    });
    test('kanbanPriorityHigh', () {
      expect(MermaidTheme.defaultTheme.kanbanPriorityHigh.value, 0xffffa500);
    });
    test('kanbanPriorityLow', () {
      expect(MermaidTheme.defaultTheme.kanbanPriorityLow.value, 0xff0000ff);
    });
    test('kanbanPriorityVeryLow', () {
      expect(MermaidTheme.defaultTheme.kanbanPriorityVeryLow.value, 0xffadd8e6);
    });
    test('c4PersonFill', () {
      expect(MermaidTheme.defaultTheme.c4PersonFill.value, 0xff08427b);
    });
    test('c4PersonBorder', () {
      expect(MermaidTheme.defaultTheme.c4PersonBorder.value, 0xff073b6f);
    });
    test('c4PersonExtFill', () {
      expect(MermaidTheme.defaultTheme.c4PersonExtFill.value, 0xff686868);
    });
    test('c4PersonExtBorder', () {
      expect(MermaidTheme.defaultTheme.c4PersonExtBorder.value, 0xff8a8a8a);
    });
    test('c4SystemFill', () {
      expect(MermaidTheme.defaultTheme.c4SystemFill.value, 0xff1168bd);
    });
    test('c4SystemBorder', () {
      expect(MermaidTheme.defaultTheme.c4SystemBorder.value, 0xff3c7fc0);
    });
    test('c4SystemExtFill', () {
      expect(MermaidTheme.defaultTheme.c4SystemExtFill.value, 0xff999999);
    });
    test('c4SystemExtBorder', () {
      expect(MermaidTheme.defaultTheme.c4SystemExtBorder.value, 0xff8a8a8a);
    });
    test('c4QueueFill', () {
      expect(MermaidTheme.defaultTheme.c4QueueFill.value, 0xff1168bd);
    });
    test('c4QueueBorder', () {
      expect(MermaidTheme.defaultTheme.c4QueueBorder.value, 0xff3c7fc0);
    });
    test('c4ContainerFill', () {
      expect(MermaidTheme.defaultTheme.c4ContainerFill.value, 0xff438dd5);
    });
    test('c4ContainerBorder', () {
      expect(MermaidTheme.defaultTheme.c4ContainerBorder.value, 0xff3c7fc0);
    });
    test('c4ComponentFill', () {
      expect(MermaidTheme.defaultTheme.c4ComponentFill.value, 0xff85bbf0);
    });
    test('c4ComponentBorder', () {
      expect(MermaidTheme.defaultTheme.c4ComponentBorder.value, 0xff78a8d8);
    });
    test('c4ExternalPersonFill', () {
      expect(MermaidTheme.defaultTheme.c4ExternalPersonFill.value, 0xff686868);
    });
    test('c4ExternalPersonBorder', () {
      expect(
        MermaidTheme.defaultTheme.c4ExternalPersonBorder.value,
        0xff8a8a8a,
      );
    });
    test('c4ExternalSystemFill', () {
      expect(MermaidTheme.defaultTheme.c4ExternalSystemFill.value, 0xff999999);
    });
    test('c4ExternalSystemBorder', () {
      expect(
        MermaidTheme.defaultTheme.c4ExternalSystemBorder.value,
        0xff8a8a8a,
      );
    });
    test('c4ExternalContainerFill', () {
      expect(
        MermaidTheme.defaultTheme.c4ExternalContainerFill.value,
        0xffb3b3b3,
      );
    });
    test('c4ExternalContainerBorder', () {
      expect(
        MermaidTheme.defaultTheme.c4ExternalContainerBorder.value,
        0xffa6a6a6,
      );
    });
    test('c4ExternalComponentFill', () {
      expect(
        MermaidTheme.defaultTheme.c4ExternalComponentFill.value,
        0xffcccccc,
      );
    });
    test('c4ExternalComponentBorder', () {
      expect(
        MermaidTheme.defaultTheme.c4ExternalComponentBorder.value,
        0xffbfbfbf,
      );
    });
    test('c4BoundaryColor', () {
      expect(MermaidTheme.defaultTheme.c4BoundaryColor.value, 0xff444444);
    });
    test('c4TextColor', () {
      expect(MermaidTheme.defaultTheme.c4TextColor.value, 0xff444444);
    });
    test('wardleyAxisColor', () {
      expect(MermaidTheme.defaultTheme.wardleyAxisColor.value, 0xff000000);
    });
    test('wardleyAxisTextColor', () {
      expect(MermaidTheme.defaultTheme.wardleyAxisTextColor.value, 0xff222222);
    });
    test('wardleyComponentFill', () {
      expect(MermaidTheme.defaultTheme.wardleyComponentFill.value, 0xffffffff);
    });
    test('wardleyComponentStroke', () {
      expect(
        MermaidTheme.defaultTheme.wardleyComponentStroke.value,
        0xff000000,
      );
    });
    test('wardleyComponentLabelColor', () {
      expect(
        MermaidTheme.defaultTheme.wardleyComponentLabelColor.value,
        0xff222222,
      );
    });
    test('wardleyLinkStroke', () {
      expect(MermaidTheme.defaultTheme.wardleyLinkStroke.value, 0xff000000);
    });
    test('wardleyEvolutionStroke', () {
      expect(
        MermaidTheme.defaultTheme.wardleyEvolutionStroke.value,
        0xffdc3545,
      );
    });
    test('wardleyAnnotationStroke', () {
      expect(
        MermaidTheme.defaultTheme.wardleyAnnotationStroke.value,
        0xff000000,
      );
    });
    test('wardleyOutsourceFill', () {
      expect(MermaidTheme.defaultTheme.wardleyOutsourceFill.value, 0xff666666);
    });
    test('wardleyBuyFill', () {
      expect(MermaidTheme.defaultTheme.wardleyBuyFill.value, 0xffcccccc);
    });
    test('wardleyBuildFill', () {
      expect(MermaidTheme.defaultTheme.wardleyBuildFill.value, 0xffeeeeee);
    });
    test('emUiFill', () {
      expect(MermaidTheme.defaultTheme.emUiFill.value, 0xffffffff);
    });
    test('emUiStroke', () {
      expect(MermaidTheme.defaultTheme.emUiStroke.value, 0xffdbdada);
    });
    test('emProcessorFill', () {
      expect(MermaidTheme.defaultTheme.emProcessorFill.value, 0xffedb3f6);
    });
    test('emProcessorStroke', () {
      expect(MermaidTheme.defaultTheme.emProcessorStroke.value, 0xffb88cbf);
    });
    test('emReadModelFill', () {
      expect(MermaidTheme.defaultTheme.emReadModelFill.value, 0xffd3f1a2);
    });
    test('emReadModelStroke', () {
      expect(MermaidTheme.defaultTheme.emReadModelStroke.value, 0xffa3b732);
    });
    test('emCommandFill', () {
      expect(MermaidTheme.defaultTheme.emCommandFill.value, 0xffbcd6fe);
    });
    test('emCommandStroke', () {
      expect(MermaidTheme.defaultTheme.emCommandStroke.value, 0xff679ac3);
    });
    test('emEventFill', () {
      expect(MermaidTheme.defaultTheme.emEventFill.value, 0xffffb778);
    });
    test('emEventStroke', () {
      expect(MermaidTheme.defaultTheme.emEventStroke.value, 0xffc19a0f);
    });
    test('emUnknownTypeFill', () {
      expect(MermaidTheme.defaultTheme.emUnknownTypeFill.value, 0xffff0000);
    });
    test('emSwimlaneBackgroundOdd', () {
      expect(
        MermaidTheme.defaultTheme.emSwimlaneBackgroundOdd.value,
        0xfffafafa,
      );
    });
    test('emSwimlaneBackgroundStroke', () {
      expect(
        MermaidTheme.defaultTheme.emSwimlaneBackgroundStroke.value,
        0xfff0f0f0,
      );
    });
    test('journeyFaceFill', () {
      expect(MermaidTheme.defaultTheme.journeyFaceFill.value, 0xfffff8dc);
    });
    test('journeyFaceBorder', () {
      expect(MermaidTheme.defaultTheme.journeyFaceBorder.value, 0xff999999);
    });
    test('journeyFaceEyeColor', () {
      expect(MermaidTheme.defaultTheme.journeyFaceEyeColor.value, 0xff666666);
    });
    test('journeyActorColors', () {
      expect(MermaidTheme.defaultTheme.journeyActorColors.map((c) => c.value), [
        0xff8fbc8f,
        0xff7cfc00,
        0xff00ffff,
        0xff20b2aa,
        0xffb0e0e6,
        0xffffffe0,
      ]);
    });
    test('sankeyColorPalette', () {
      expect(MermaidTheme.defaultTheme.sankeyColorPalette.map((c) => c.value), [
        0xff4e79a7,
        0xfff28e2c,
        0xffe15759,
        0xff76b7b2,
        0xff59a14f,
        0xffedc949,
        0xffaf7aa1,
        0xffff9da7,
        0xff9c755f,
        0xffbab0ab,
      ]);
    });
    test('cynefinComplexFill', () {
      expect(MermaidTheme.defaultTheme.cynefinComplexFill.value, 0xffe8f5e9);
    });
    test('cynefinComplicatedFill', () {
      expect(
        MermaidTheme.defaultTheme.cynefinComplicatedFill.value,
        0xffe3f2fd,
      );
    });
    test('cynefinClearFill', () {
      expect(MermaidTheme.defaultTheme.cynefinClearFill.value, 0xfffff8e1);
    });
    test('cynefinChaoticFill', () {
      expect(MermaidTheme.defaultTheme.cynefinChaoticFill.value, 0xfffbe9e7);
    });
    test('cynefinConfusionFill', () {
      expect(MermaidTheme.defaultTheme.cynefinConfusionFill.value, 0xfff3e5f5);
    });
    test('cynefinCliffColor', () {
      expect(MermaidTheme.defaultTheme.cynefinCliffColor.value, 0xff8b0000);
    });
  });

  group('copyWith reaches every diagram token', () {
    // mermaid.js exposes every color as a theme variable, so a host
    // must be able to override every one of them. A token that
    // copyWith silently drops is a token the host cannot theme.
    const probe = Color(0xff123456);
    final base = MermaidTheme.defaultTheme;
    final overridden = base.copyWith(
      canvasColor: probe,
      textOnDarkFill: probe,
      textOnLightFill: probe,
      tertiaryColor: probe,
      ganttTaskBkgColor: probe,
      ganttTaskBorderColor: probe,
      ganttActiveTaskBkgColor: probe,
      ganttActiveTaskBorderColor: probe,
      ganttDoneTaskBkgColor: probe,
      ganttDoneTaskBorderColor: probe,
      ganttCritBkgColor: probe,
      ganttCritBorderColor: probe,
      ganttTaskTextColor: probe,
      ganttActiveTaskTextColor: probe,
      ganttDoneTaskTextColor: probe,
      ganttCritTaskTextColor: probe,
      ganttTaskTextOutsideColor: probe,
      ganttExcludeBkgColor: probe,
      ganttGridColor: probe,
      ganttTodayLineColor: probe,
      ganttSectionBkgColors: const [probe],
      sequenceAltFrameColor: probe,
      gitMergeInnerColor: probe,
      railroadSpecialFill: probe,
      railroadSpecialStroke: probe,
      radarGraticuleColor: probe,
      packetBlockFill: probe,
      packetBlockBorder: probe,
      packetTextColor: probe,
      kanbanPriorityVeryHigh: probe,
      kanbanPriorityHigh: probe,
      kanbanPriorityLow: probe,
      kanbanPriorityVeryLow: probe,
      c4PersonFill: probe,
      c4PersonBorder: probe,
      c4PersonExtFill: probe,
      c4PersonExtBorder: probe,
      c4SystemFill: probe,
      c4SystemBorder: probe,
      c4SystemExtFill: probe,
      c4SystemExtBorder: probe,
      c4QueueFill: probe,
      c4QueueBorder: probe,
      c4ContainerFill: probe,
      c4ContainerBorder: probe,
      c4ComponentFill: probe,
      c4ComponentBorder: probe,
      c4ExternalPersonFill: probe,
      c4ExternalPersonBorder: probe,
      c4ExternalSystemFill: probe,
      c4ExternalSystemBorder: probe,
      c4ExternalContainerFill: probe,
      c4ExternalContainerBorder: probe,
      c4ExternalComponentFill: probe,
      c4ExternalComponentBorder: probe,
      c4BoundaryColor: probe,
      c4TextColor: probe,
      wardleyAxisColor: probe,
      wardleyAxisTextColor: probe,
      wardleyComponentFill: probe,
      wardleyComponentStroke: probe,
      wardleyComponentLabelColor: probe,
      wardleyLinkStroke: probe,
      wardleyEvolutionStroke: probe,
      wardleyAnnotationStroke: probe,
      wardleyOutsourceFill: probe,
      wardleyBuyFill: probe,
      wardleyBuildFill: probe,
      emUiFill: probe,
      emUiStroke: probe,
      emProcessorFill: probe,
      emProcessorStroke: probe,
      emReadModelFill: probe,
      emReadModelStroke: probe,
      emCommandFill: probe,
      emCommandStroke: probe,
      emEventFill: probe,
      emEventStroke: probe,
      emUnknownTypeFill: probe,
      emSwimlaneBackgroundOdd: probe,
      emSwimlaneBackgroundStroke: probe,
      journeyFaceFill: probe,
      journeyFaceBorder: probe,
      journeyFaceEyeColor: probe,
      journeyActorColors: const [probe],
      sankeyColorPalette: const [probe],
      cynefinComplexFill: probe,
      cynefinComplicatedFill: probe,
      cynefinClearFill: probe,
      cynefinChaoticFill: probe,
      cynefinConfusionFill: probe,
      cynefinCliffColor: probe,
    );
    test('every diagram token is reachable', () {
      expect(overridden.canvasColor, probe, reason: 'canvasColor');
      expect(overridden.textOnDarkFill, probe, reason: 'textOnDarkFill');
      expect(overridden.textOnLightFill, probe, reason: 'textOnLightFill');
      expect(overridden.tertiaryColor, probe, reason: 'tertiaryColor');
      expect(overridden.ganttTaskBkgColor, probe, reason: 'ganttTaskBkgColor');
      expect(
        overridden.ganttTaskBorderColor,
        probe,
        reason: 'ganttTaskBorderColor',
      );
      expect(
        overridden.ganttActiveTaskBkgColor,
        probe,
        reason: 'ganttActiveTaskBkgColor',
      );
      expect(
        overridden.ganttActiveTaskBorderColor,
        probe,
        reason: 'ganttActiveTaskBorderColor',
      );
      expect(
        overridden.ganttDoneTaskBkgColor,
        probe,
        reason: 'ganttDoneTaskBkgColor',
      );
      expect(
        overridden.ganttDoneTaskBorderColor,
        probe,
        reason: 'ganttDoneTaskBorderColor',
      );
      expect(overridden.ganttCritBkgColor, probe, reason: 'ganttCritBkgColor');
      expect(
        overridden.ganttCritBorderColor,
        probe,
        reason: 'ganttCritBorderColor',
      );
      expect(
        overridden.ganttTaskTextColor,
        probe,
        reason: 'ganttTaskTextColor',
      );
      expect(
        overridden.ganttActiveTaskTextColor,
        probe,
        reason: 'ganttActiveTaskTextColor',
      );
      expect(
        overridden.ganttDoneTaskTextColor,
        probe,
        reason: 'ganttDoneTaskTextColor',
      );
      expect(
        overridden.ganttCritTaskTextColor,
        probe,
        reason: 'ganttCritTaskTextColor',
      );
      expect(
        overridden.ganttTaskTextOutsideColor,
        probe,
        reason: 'ganttTaskTextOutsideColor',
      );
      expect(
        overridden.ganttExcludeBkgColor,
        probe,
        reason: 'ganttExcludeBkgColor',
      );
      expect(overridden.ganttGridColor, probe, reason: 'ganttGridColor');
      expect(
        overridden.ganttTodayLineColor,
        probe,
        reason: 'ganttTodayLineColor',
      );
      expect(overridden.ganttSectionBkgColors, const [
        probe,
      ], reason: 'ganttSectionBkgColors');
      expect(
        overridden.sequenceAltFrameColor,
        probe,
        reason: 'sequenceAltFrameColor',
      );
      expect(
        overridden.gitMergeInnerColor,
        probe,
        reason: 'gitMergeInnerColor',
      );
      expect(
        overridden.railroadSpecialFill,
        probe,
        reason: 'railroadSpecialFill',
      );
      expect(
        overridden.railroadSpecialStroke,
        probe,
        reason: 'railroadSpecialStroke',
      );
      expect(
        overridden.radarGraticuleColor,
        probe,
        reason: 'radarGraticuleColor',
      );
      expect(overridden.packetBlockFill, probe, reason: 'packetBlockFill');
      expect(overridden.packetBlockBorder, probe, reason: 'packetBlockBorder');
      expect(overridden.packetTextColor, probe, reason: 'packetTextColor');
      expect(
        overridden.kanbanPriorityVeryHigh,
        probe,
        reason: 'kanbanPriorityVeryHigh',
      );
      expect(
        overridden.kanbanPriorityHigh,
        probe,
        reason: 'kanbanPriorityHigh',
      );
      expect(overridden.kanbanPriorityLow, probe, reason: 'kanbanPriorityLow');
      expect(
        overridden.kanbanPriorityVeryLow,
        probe,
        reason: 'kanbanPriorityVeryLow',
      );
      expect(overridden.c4PersonFill, probe, reason: 'c4PersonFill');
      expect(overridden.c4PersonBorder, probe, reason: 'c4PersonBorder');
      expect(overridden.c4PersonExtFill, probe, reason: 'c4PersonExtFill');
      expect(overridden.c4PersonExtBorder, probe, reason: 'c4PersonExtBorder');
      expect(overridden.c4SystemFill, probe, reason: 'c4SystemFill');
      expect(overridden.c4SystemBorder, probe, reason: 'c4SystemBorder');
      expect(overridden.c4SystemExtFill, probe, reason: 'c4SystemExtFill');
      expect(overridden.c4SystemExtBorder, probe, reason: 'c4SystemExtBorder');
      expect(overridden.c4QueueFill, probe, reason: 'c4QueueFill');
      expect(overridden.c4QueueBorder, probe, reason: 'c4QueueBorder');
      expect(overridden.c4ContainerFill, probe, reason: 'c4ContainerFill');
      expect(overridden.c4ContainerBorder, probe, reason: 'c4ContainerBorder');
      expect(overridden.c4ComponentFill, probe, reason: 'c4ComponentFill');
      expect(overridden.c4ComponentBorder, probe, reason: 'c4ComponentBorder');
      expect(
        overridden.c4ExternalPersonFill,
        probe,
        reason: 'c4ExternalPersonFill',
      );
      expect(
        overridden.c4ExternalPersonBorder,
        probe,
        reason: 'c4ExternalPersonBorder',
      );
      expect(
        overridden.c4ExternalSystemFill,
        probe,
        reason: 'c4ExternalSystemFill',
      );
      expect(
        overridden.c4ExternalSystemBorder,
        probe,
        reason: 'c4ExternalSystemBorder',
      );
      expect(
        overridden.c4ExternalContainerFill,
        probe,
        reason: 'c4ExternalContainerFill',
      );
      expect(
        overridden.c4ExternalContainerBorder,
        probe,
        reason: 'c4ExternalContainerBorder',
      );
      expect(
        overridden.c4ExternalComponentFill,
        probe,
        reason: 'c4ExternalComponentFill',
      );
      expect(
        overridden.c4ExternalComponentBorder,
        probe,
        reason: 'c4ExternalComponentBorder',
      );
      expect(overridden.c4BoundaryColor, probe, reason: 'c4BoundaryColor');
      expect(overridden.c4TextColor, probe, reason: 'c4TextColor');
      expect(overridden.wardleyAxisColor, probe, reason: 'wardleyAxisColor');
      expect(
        overridden.wardleyAxisTextColor,
        probe,
        reason: 'wardleyAxisTextColor',
      );
      expect(
        overridden.wardleyComponentFill,
        probe,
        reason: 'wardleyComponentFill',
      );
      expect(
        overridden.wardleyComponentStroke,
        probe,
        reason: 'wardleyComponentStroke',
      );
      expect(
        overridden.wardleyComponentLabelColor,
        probe,
        reason: 'wardleyComponentLabelColor',
      );
      expect(overridden.wardleyLinkStroke, probe, reason: 'wardleyLinkStroke');
      expect(
        overridden.wardleyEvolutionStroke,
        probe,
        reason: 'wardleyEvolutionStroke',
      );
      expect(
        overridden.wardleyAnnotationStroke,
        probe,
        reason: 'wardleyAnnotationStroke',
      );
      expect(
        overridden.wardleyOutsourceFill,
        probe,
        reason: 'wardleyOutsourceFill',
      );
      expect(overridden.wardleyBuyFill, probe, reason: 'wardleyBuyFill');
      expect(overridden.wardleyBuildFill, probe, reason: 'wardleyBuildFill');
      expect(overridden.emUiFill, probe, reason: 'emUiFill');
      expect(overridden.emUiStroke, probe, reason: 'emUiStroke');
      expect(overridden.emProcessorFill, probe, reason: 'emProcessorFill');
      expect(overridden.emProcessorStroke, probe, reason: 'emProcessorStroke');
      expect(overridden.emReadModelFill, probe, reason: 'emReadModelFill');
      expect(overridden.emReadModelStroke, probe, reason: 'emReadModelStroke');
      expect(overridden.emCommandFill, probe, reason: 'emCommandFill');
      expect(overridden.emCommandStroke, probe, reason: 'emCommandStroke');
      expect(overridden.emEventFill, probe, reason: 'emEventFill');
      expect(overridden.emEventStroke, probe, reason: 'emEventStroke');
      expect(overridden.emUnknownTypeFill, probe, reason: 'emUnknownTypeFill');
      expect(
        overridden.emSwimlaneBackgroundOdd,
        probe,
        reason: 'emSwimlaneBackgroundOdd',
      );
      expect(
        overridden.emSwimlaneBackgroundStroke,
        probe,
        reason: 'emSwimlaneBackgroundStroke',
      );
      expect(overridden.journeyFaceFill, probe, reason: 'journeyFaceFill');
      expect(overridden.journeyFaceBorder, probe, reason: 'journeyFaceBorder');
      expect(
        overridden.journeyFaceEyeColor,
        probe,
        reason: 'journeyFaceEyeColor',
      );
      expect(overridden.journeyActorColors, const [
        probe,
      ], reason: 'journeyActorColors');
      expect(overridden.sankeyColorPalette, const [
        probe,
      ], reason: 'sankeyColorPalette');
      expect(
        overridden.cynefinComplexFill,
        probe,
        reason: 'cynefinComplexFill',
      );
      expect(
        overridden.cynefinComplicatedFill,
        probe,
        reason: 'cynefinComplicatedFill',
      );
      expect(overridden.cynefinClearFill, probe, reason: 'cynefinClearFill');
      expect(
        overridden.cynefinChaoticFill,
        probe,
        reason: 'cynefinChaoticFill',
      );
      expect(
        overridden.cynefinConfusionFill,
        probe,
        reason: 'cynefinConfusionFill',
      );
      expect(overridden.cynefinCliffColor, probe, reason: 'cynefinCliffColor');
    });
  });
}
