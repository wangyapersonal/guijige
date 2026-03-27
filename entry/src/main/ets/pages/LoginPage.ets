/**
 * 登录页
 */

import { AuthService } from '../services/AuthService';
import { Router } from '@kit.ArkUI';

@Entry
@Component
struct LoginPage {
  @State isLoading: boolean = false;
  @State isLoggedIn: boolean = false;
  
  private authService: AuthService = AuthService.getInstance();
  
  aboutToAppear() {
    this.isLoggedIn = this.authService.isLoggedIn();
    if (this.isLoggedIn) {
      // 已登录，跳转首页
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
      .margin({ top: 120, bottom: 80 })
      
      // 登录按钮区域
      Column({ space: 20 }) {
        // 华为账号登录
        Button() {
          Row({ space: 12 }) {
            Text('H')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
            
            Text('华为账号登录')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
          }
        }
        .width('85%')
        .height(50)
        .backgroundColor('#CF0A2C')
        .borderRadius(25)
        .enabled(!this.isLoading)
        .onClick(() => this.handleLogin())
        
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
        .margin({ top: 20, bottom: 20 })
        
        // 手机号登录
        Button() {
          Row({ space: 12 }) {
            Text('📱')
              .fontSize(20)
            
            Text('手机号登录')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#212121')
          }
        }
        .width('85%')
        .height(50)
        .backgroundColor(Color.White)
        .borderRadius(25)
        .border({ width: 1, color: '#E0E0E0' })
        .enabled(!this.isLoading)
      }
      .width('100%')
      .margin({ top: 60 })
      
      Blank()
      
      // 底部协议
      Column() {
        Text('登录即表示同意')
          .fontSize(12)
          .fontColor('#9E9E9E')
        
        Row() {
          Text('《用户协议》')
            .fontSize(12)
            .fontColor('#2196F3')
            .onClick(() => {
              // TODO: 打开用户协议
            })
          
          Text('和')
            .fontSize(12)
            .fontColor('#9E9E9E')
          
          Text('《隐私政策》')
            .fontSize(12)
            .fontColor('#2196F3')
            .onClick(() => {
              // TODO: 打开隐私政策
            })
        }
      }
      .margin({ bottom: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
  }
  
  private async handleLogin() {
    this.isLoading = true;
    
    try {
      const user = await this.authService.loginWithHuawei();
      if (user) {
        this.goToHome();
      } else {
        // TODO: 显示错误提示
        console.error('Login failed');
      }
    } catch (error) {
      console.error('Login error', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  private goToHome() {
    // TODO: 跳转首页
    console.info('Go to home');
  }
}
