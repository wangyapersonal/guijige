/**
 * 应用颜色常量
 * 基于 V2 设计规范
 */

export interface CommonShadow {
  radius: number;
  color: string;
  offsetY: number;
}

export class AppColors {
  // ==================== 主色系 ====================
  /** 主色 - 青色 */
  static readonly Primary = '#14B8A6';

  /** 主色深色 */
  static readonly PrimaryDark = '#0D9488';

  /** 主色浅色 */
  static readonly PrimaryLight = '#5EEAD4';

  /** 主色更浅色 */
  static readonly PrimaryLighter = '#99F6E4';

  /** 主色半透明 - 10% */
  static readonly PrimaryAlpha10 = 'rgba(20, 184, 166, 0.1)';

  /** 主色半透明 - 20% */
  static readonly PrimaryAlpha20 = 'rgba(20, 184, 166, 0.2)';

  /** 主色半透明 - 30% */
  static readonly PrimaryAlpha30 = 'rgba(20, 184, 166, 0.3)';

  // ==================== 辅助色 ====================
  /** 辅助色 - 金色/橙色 */
  static readonly Accent = '#F59E0B';

  /** 辅助色深色 */
  static readonly AccentDark = '#D97706';

  /** 辅助色浅色 */
  static readonly AccentLight = '#FCD34D';

  /** 辅助色半透明 - 10% */
  static readonly AccentAlpha10 = 'rgba(245, 158, 11, 0.1)';

  // ==================== 文字色 ====================
  /** 主文字 */
  static readonly TextPrimary = '#1F2937';

  /** 次要文字 */
  static readonly TextSecondary = '#6B7280';

  /** 三级文字 */
  static readonly TextTertiary = '#9CA3AF';

  /** 占位符文字 */
  static readonly TextPlaceholder = '#D1D5DB';

  // ==================== 背景色 ====================
  /** 页面背景 */
  static readonly Background = '#F7F9FA';

  /** 卡片背景 */
  static readonly CardBackground = '#FFFFFF';

  /** 分割线 */
  static readonly Divider = '#E5E7EB';

  /** 边框 */
  static readonly Border = '#F3F4F6';

  // ==================== 状态色 ====================
  /** 成功 */
  static readonly Success = '#10B981';

  /** 警告 */
  static readonly Warning = '#F59E0B';

  /** 错误 */
  static readonly Error = '#EF4444';

  /** 信息 */
  static readonly Info = '#3B82F6';

  // ==================== 深色模式 ====================
  /** 深色背景 */
  static readonly DarkBackground = '#111827';

  /** 深色卡片背景 */
  static readonly DarkCardBackground = '#1F2937';

  /** 深色文字 */
  static readonly DarkTextPrimary = '#F9FAFB';

  /** 深色次要文字 */
  static readonly DarkTextSecondary = '#9CA3AF';

  // ==================== 透明色 ====================
  /** 白色半透明 - 10% */
  static readonly WhiteAlpha10 = 'rgba(255, 255, 255, 0.1)';

  /** 白色半透明 - 20% */
  static readonly WhiteAlpha20 = 'rgba(255, 255, 255, 0.2)';

  /** 白色半透明 - 85% (毛玻璃效果) */
  static readonly WhiteAlpha85 = 'rgba(255, 255, 255, 0.85)';

  /** 黑色半透明 - 20% */
  static readonly BlackAlpha20 = 'rgba(0, 0, 0, 0.2)';

  /** 黑色半透明 - 40% */
  static readonly BlackAlpha40 = 'rgba(0, 0, 0, 0.4)';

  /** 黑色半透明 - 60% */
  static readonly BlackAlpha60 = 'rgba(0, 0, 0, 0.6)';

  // ==================== 渐变色 ====================
  /** 主色渐变 */
  static readonly GradientPrimary: [string, string] = ['#14B8A6', '#0D9488'];

  /** 辅助色渐变 */
  static readonly GradientAccent: [string, string] = ['#F59E0B', '#F97316'];

  /** 错误色渐变 */
  static readonly GradientError: [string, string] = ['#EF4444', '#DC2626'];

  /** 深色渐变 */
  static readonly GradientDark: [string, string] = ['#111827', '#1F2937'];
}

/**
 * 阴影配置
 */
export class AppShadows {
  private static readonly shadowType: CommonShadow = {
    radius: 0,
    color: '',
    offsetY: 0
  };

  /** 小阴影 */
  static readonly Small: CommonShadow = {
    radius: 8,
    color: 'rgba(0, 0, 0, 0.04)',
    offsetY: 2
  };

  /** 中等阴影 */
  static readonly Medium: CommonShadow = {
    radius: 12,
    color: 'rgba(0, 0, 0, 0.08)',
    offsetY: 4
  };

  /** 大阴影 */
  static readonly Large: CommonShadow = {
    radius: 16,
    color: 'rgba(0, 0, 0, 0.1)',
    offsetY: 8
  };

  /** 主色阴影 */
  static readonly Primary: CommonShadow = {
    radius: 12,
    color: 'rgba(20, 184, 166, 0.2)',
    offsetY: 4
  };

  /** 辅助色阴影 */
  static readonly Accent: CommonShadow = {
    radius: 12,
    color: 'rgba(245, 158, 11, 0.2)',
    offsetY: 4
  };
}

/**
 * 圆角配置
 */
export class AppRadius {
  /** 小圆角 */
  static readonly Small = 8;

  /** 中等圆角 */
  static readonly Medium = 16;

  /** 大圆角 */
  static readonly Large = 24;

  /** 超大圆角 */
  static readonly XLarge = 32;

  /** 圆形 */
  static readonly Full = 9999;
}

/**
 * 间距配置
 */
export class AppSpacing {
  /** XSmall - 4 */
  static readonly XSmall = 4;

  /** Small - 8 */
  static readonly Small = 8;

  /** Medium - 16 */
  static readonly Medium = 16;

  /** Large - 24 */
  static readonly Large = 24;

  /** XLarge - 32 */
  static readonly XLarge = 32;

  /** XXLarge - 48 */
  static readonly XXLarge = 48;
}
