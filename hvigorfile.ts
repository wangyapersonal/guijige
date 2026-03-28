import { Hvigor } from '@ohos/hvigor';
import { HvigorNode, HvigorContext } from '@ohos/hvigor';
import { HvigorNodePlugin } from '@ohos/hvigor-arkts-plugin';
import { HvigorPlugin } from '@ohos/hvigor-ohos-plugin';

export default {
  system: Hvigor,
  plugins: (ctx: HvigorContext<HvigorNode>) => {
    return new HvigorPlugin(ctx)
  },
  plugins: (ctx: HvigorContext<HvigorNode>) => {
    return new HvigorNodePlugin(ctx)
  }
} as HvigorNode;
