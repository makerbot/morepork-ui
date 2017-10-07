#include <QList>
#include <QNetworkInterface>

void getMacAddress(QString &eth_mac_addr, QString &wlan_mac_addr){
  eth_mac_addr.clear();
  wlan_mac_addr.clear();
  QList<QNetworkInterface> all_interfaces = QNetworkInterface::allInterfaces();
  for(size_t i = 0 ; i < all_interfaces.size(); ++i)
  {
    const QNetworkInterface &interface = all_interfaces[i];
    if(!(interface.flags() & QNetworkInterface::IsLoopBack))
    {
      if(interface.name() == "eth0")
      {
          eth_mac_addr = interface.hardwareAddress();
      }
      else if(interface.name() == "wlan0")
      {
          wlan_mac_addr = interface.hardwareAddress();
      }
    }
  }
}

