/**
 * 登录页 - 集成华为账号登录
 */

import { AuthService } from '../services/AuthService';
import { Router } from '@kit.ArkUI';
import { common } from '@kit.Ability';

@Entry
@Component
struct LoginPage {
  @State isLoading: boolean = false;
  @State isLoggedIn: boolean = false;
  @State errorMessage: string = '';
  @State showAgreement: boolean = false;
  @State agreedToTerms: boolean = false;
  
  private authService: AuthService = AuthService.getInstance();
  private context: common.UIAbilityContext | null = null;
  
  aboutToAppear() {
    // 获取上下文
    try {
      this.context = getContext(this) as common.UIAbilityContext;
    } catch (e) {
      console.warn('Failed to get context');
    }
    
    // 检查登录状态
    this.isLoggedIn = this.authService.isLoggedIn();
    if (this.isLoggedIn) {
      this.goToHome();
    }
  }
  
  build() {
    Column() {
      // Logo区域
      Column() {
        Text('🗺️')
          .fontSize(80)
          .margin({ bottom: 20 })
        
        Text('轨迹哥')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#212121')
        
        Text('记录每一次旅行的足迹')
          .fontSize(16)
          .fontColor('#757575')
          .margin({ top: 8 })
      }
      .margin({ top: 100, bottom: 60 })
      
      // 错误提示
      if (this.errorMessage) {
        Row() {
          Text('⚠️ ' + this.errorMessage)
            .fontSize(14)
            .fontColor('#D32F2F')
        }
        .width('85%')
        .padding(12)
        .backgroundColor('#FFEBEE')
        .borderRadius(8)
        .margin({ bottom: 20 })
      }
      
      // 登录按钮区域
      Column({ space: 16 }) {
        // 华为账号登录
        Button() {
          Row({ space: 12 }) {
            if (this.isLoading) {
              LoadingProgress()
                .width(20)
                .height(20)
                .color(Color.White)
            } else {
              Text('H')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
            }
            
            Text(this.isLoading ? '登录中...' : '华为账号登录')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .width('85%')
        .height(52)
        .backgroundColor('#CF0A2C')
        .borderRadius(26)
        .enabled(!this.isLoading)
        .onClick(() => this.handleHuaweiLogin())
        
        // 分割线
        Row() {
          Divider()
            .width(80)
            .color('#E0E0E0')
          
          Text('其他方式')
            .fontSize(14)
            .fontColor('#9E9E9E')
            .margin({ left: 16, right: 16 })
          
          Divider()
            .width(80)
            .color('#E0E0E0')
        }
        .margin({ top: 16, bottom: 16 })
        
        // 游客模式（开发测试用）
        Button() {
          Row({ space: 12 }) {
            Text('👤')
              .fontSize(20)
            
            Text('游客模式（开发中）')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#212121')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .width('85%')
        .height(52)
        .backgroundColor(Color.White)
        .borderRadius(26)
        .border({ width: 1, color: '#E0E0E0' })
        .enabled(!this.isLoading)
        .onClick(() => this.handleGuestLogin())
      }
      .width('100%')
      
      Blank()
      
      // 底部协议
      Column() {
        Row({ space: 8 }) {
          Checkbox()
            .select(this.agreedToTerms)
            .selectedColor('#2196F3')
            .onChange((checked) => {
              this.agreedToTerms = checked;
            })
          
          Text('登录即表示同意')
            .fontSize(12)
            .fontColor('#9E9E9E')
        }
        
        Row() {
          Text('《用户协议》')
            .fontSize(12)
            .fontColor('#2196F3')
            .onClick(() => this.openUserAgreement())
          
          Text('和')
            .fontSize(12)
            .fontColor('#9E9E9E')
          
          Text('《隐私政策》')
            .fontSize(12)
            .fontColor('#2196F3')
            .onClick(() => this.openPrivacyPolicy())
        }
        .margin({ top: 4 })
      }
      .margin({ bottom: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
  }
  
  /**
   * 华为账号登录
   */
  private async handleHuaweiLogin() {
    if (!this.agreedToTerms) {
      this.errorMessage = '请先同意用户协议和隐私政策';
      return;
    }
    
    this.isLoading = true;
    this.errorMessage = '';
    
    try {
      const user = await this.authService.loginWithHuawei();
      if (user) {
        console.info('LoginPage', 'Login success:', user.displayName);
        this.goToHome();
      } else {
        this.errorMessage = '登录失败，请重试';
      }
    } catch (error) {
      console.error('LoginPage', 'Login error', error);
      this.errorMessage = '登录出错：' + (error as Error).message;
    } finally {
      this.isLoading = false;
    }
  }
  
  /**
   * 游客登录（开发测试）
   */
  private async handleGuestLogin() {
    this.isLoading = true;
    this.errorMessage = '';
    
    try {
      // 直接使用模拟登录
      const user = await this.authService.loginWithHuawei();
      if (user) {
        this.goToHome();
      }
    } catch (error) {
      this.errorMessage = '登录失败';
    } finally {
      this.isLoading = false;
    }
  }
  
  /**
   * 跳转首页
   */
  private goToHome() {
    Router.replaceUrl({
      url: 'pages/Index'
    }).catch((err) => {
      console.error('LoginPage', 'Navigation error', err);
    });
  }
  
  /**
   * 打开用户协议
   */
  private openUserAgreement() {
    // TODO: 打开用户协议页面
    console.info('Open user agreement');
  }
  
  /**
   * 打开隐私政策
   */
  private openPrivacyPolicy() {
    // TODO: 打开隐私政策页面
    console.info('Open privacy policy');
  }
}
