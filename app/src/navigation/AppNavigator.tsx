import { createDrawerNavigator } from '@react-navigation/drawer';
import { NavigationContainer } from '@react-navigation/native';
import React from 'react';
import { AccountsScreen } from '../screens/AccountsScreen';
import { AnalyticsScreen } from '../screens/AnalyticsScreen';
import { BalancesScreen } from '../screens/BalancesScreen';
import { CashFlowScreen } from '../screens/CashFlowScreen';
import { CategoriesScreen } from '../screens/CategoriesScreen';
import { DashboardScreen } from '../screens/DashboardScreen';
import { SettingsScreen } from '../screens/SettingsScreen';
import { TransactionsScreen } from '../screens/TransactionsScreen';
import { Sidebar } from './Sidebar';
import { AppColors } from '../theme/colors';

const Drawer = createDrawerNavigator();

export function AppNavigator() {
  return (
    <NavigationContainer>
      <Drawer.Navigator
        drawerContent={(props) => <Sidebar {...props} />}
        screenOptions={{
          drawerType: 'permanent',
          drawerStyle: {
            width: 220,
            backgroundColor: AppColors.sidebarBg,
          },
          headerShown: false,
          sceneStyle: {
            backgroundColor: AppColors.background,
          },
        }}
      >
        <Drawer.Screen name="Dashboard" component={DashboardScreen} />
        <Drawer.Screen name="CashFlow" component={CashFlowScreen} />
        <Drawer.Screen name="Transactions" component={TransactionsScreen} />
        <Drawer.Screen name="Accounts" component={AccountsScreen} />
        <Drawer.Screen name="Balances" component={BalancesScreen} />
        <Drawer.Screen name="Analytics" component={AnalyticsScreen} />
        <Drawer.Screen name="Categories" component={CategoriesScreen} />
        <Drawer.Screen name="Settings" component={SettingsScreen} />
      </Drawer.Navigator>
    </NavigationContainer>
  );
}
