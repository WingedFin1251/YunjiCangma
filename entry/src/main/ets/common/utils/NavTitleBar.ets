import { HdsNavigationTitleBarOptions, hdsMaterial, BlurStrategy, ScrollEffectType } from '@kit.UIDesignKit';
import { LengthMetrics } from '@kit.ArkUI';

/**
 * 子页面沉浸毛玻璃标题栏（内容滚入栏下触发模糊）
 * 使用时内容区 Scroll 顶部需加 Blank().height(88)（56vp 标题栏 + 32vp 状态栏）
 */
export function buildTitleBar(title: ResourceStr): HdsNavigationTitleBarOptions {
  return {
    content: {
      title: {
        mainTitle: title
      }
    },
    avoidLayoutSafeArea: true,
    style: {
      scrollEffectOpts: {
        enableScrollEffect: true,
        scrollEffectType: ScrollEffectType.IMMERSIVE_GRADIENT_BLUR,
        blurEffectiveStartOffset: LengthMetrics.vp(0),
        blurEffectiveEndOffset: LengthMetrics.vp(20)
      },
      blurStrategy: BlurStrategy.ENABLE,
      systemMaterialEffect: {
        materialType: hdsMaterial.MaterialType.IMMERSIVE,
        materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
      }
    }
  };
}
