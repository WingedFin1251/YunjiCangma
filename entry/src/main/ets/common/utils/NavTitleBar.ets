import { HdsNavigationTitleBarOptions, hdsMaterial, BlurStrategy } from '@kit.UIDesignKit';

/** 子页面沉浸毛玻璃标题栏（内容滚入栏下触发模糊） */
export function buildTitleBar(title: ResourceStr): HdsNavigationTitleBarOptions {
  return {
    content: {
      title: {
        mainTitle: title
      }
    },
    avoidLayoutSafeArea: true, // 标题/返回键避让状态栏（保持沉浸背景延伸，内容不自动避让标题栏）
    style: {
      blurStrategy: BlurStrategy.ENABLE,
      systemMaterialEffect: {
        materialType: hdsMaterial.MaterialType.IMMERSIVE,
        materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
      }
    }
  };
}
