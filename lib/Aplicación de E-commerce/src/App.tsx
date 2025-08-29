import { AppProvider, useApp } from './components/AppContext';
import { Header } from './components/Header';
import { HomeView } from './components/HomeView';
import { AuthView } from './components/AuthView';
import { BusinessesView } from './components/BusinessesView';
import { BusinessView } from './components/BusinessView';
import { CartView } from './components/CartView';
import { OrdersView } from './components/OrdersView';

function AppContent() {
  const { currentView } = useApp();

  const renderView = () => {
    switch (currentView) {
      case 'home':
        return <HomeView />;
      case 'auth':
        return <AuthView />;
      case 'businesses':
        return <BusinessesView />;
      case 'business':
        return <BusinessView />;
      case 'cart':
        return <CartView />;
      case 'orders':
        return <OrdersView />;
      default:
        return <HomeView />;
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />
      <main>
        {renderView()}
      </main>
    </div>
  );
}

export default function App() {
  return (
    <AppProvider>
      <AppContent />
    </AppProvider>
  );
}