import { hapTasks } from '@ohos/hvigor-ohos-plugin';
import { OhosTestPlugin } from '@ohos/hypium/index';

export default {
  system: hapTasks,
  plugins: [new OhosTestPlugin()]
}
