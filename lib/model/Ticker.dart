class Ticker {
  final int sequence;
  final String productId;
  final String price;
  final String low24h;
  final String high24h;
  final String side;
  final String time;
  final String lastSize;

  Ticker(this.sequence, this.productId, this.price, this.side, this.time,
      this.lastSize, high_24h, low_24h, this.high24h, this.low24h);

  Ticker.fromJson(Map<String, dynamic> json)
      : sequence = json['sequence'],
        productId = json['product_id'],
        price = json['price'],
        low24h = json['low_24h'],
        high24h = json['high_24h'],
        side = json['side'],
        time = json['time'],
        lastSize = json['last_size'];
}

class Subscriptions {
  final List channels;

  Subscriptions(this.channels);

  Subscriptions.fromJson(Map<String, dynamic> json)
      : channels = json['channels'];
}
