package org.cocos2dx.lua;

import com.umeng.analytics.game.UMGameAgent;

public class GameAnalysis {

	public static void startLevel(String level) {
		UMGameAgent.startLevel(level);
	}

	public static void failLevel(String level) {
		UMGameAgent.failLevel(level);
	}

	public static void finishLevel(String level) {
		UMGameAgent.finishLevel(level);
	}

	public static void payCoin(int money, int coin, int source) {
		UMGameAgent.pay(money, coin, source);
	}

	public static void payProps(int money, String item, int number, int price, int source) {
		UMGameAgent.pay(money, item, number, price, source);
	}

	public static void buyPropsWithCoin(String item, int number, int price) {
		UMGameAgent.buy(item, number, price);
	}

	public static void useProps(String item, int number, int price) {
		UMGameAgent.use(item, number, price);
	}

	public static void bonusCoin(int coin, int trigger) {
		UMGameAgent.bonus(coin, trigger);
	}

	public static void bonusProps(String item, int num, int price, int trigger) {
		UMGameAgent.bonus(item, num, price, trigger);
	}

	public static void setPlayerLevel(int level) {
		UMGameAgent.setPlayerLevel(level);
	}

	public static void onProfileSignIn(String ID) {
		UMGameAgent.onProfileSignIn(ID);
	}

	public static void onProfileSignIn(String Provider, String ID) {
		UMGameAgent.onProfileSignIn(Provider, ID);
	}

}
