
class NotificationBody {
  int? orderId;
  String? type;
  String? status;
  String? messageKey;
  String? title;
  String? productId;
  String? slug;
  String? image;
  int? sellerId;
  int? deliveryManId;
  String? name;


  NotificationBody({
    this.orderId,
    this.type,
    this.status,
    this.messageKey,
    this.title,
    this.productId,
    this.slug,
    this.image,
    this.sellerId,
    this.deliveryManId,
    this.name,
  });

  NotificationBody.fromJson(Map<String, dynamic> json) {
    final dynamic rawOrderId = json['order_id'];
    if (rawOrderId != null) {
      orderId = int.tryParse(rawOrderId.toString());
    }
    type = json['type']?.toString();
    messageKey = json['message_key']?.toString() ?? json['body']?.toString();
    title = json['title']?.toString();
    productId = json['product_id']?.toString();
    slug = json['slug']?.toString();
    image = json['image']?.toString();
    status = json['status']?.toString();
    sellerId = int.tryParse(json['seller_id']?.toString() ?? '');
    deliveryManId = int.tryParse(json['delivery_man_id']?.toString() ?? '');
    name = json['name']?.toString() ?? json['shop_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['type'] = type;
    data['message_key'] = messageKey;
    data['title'] = title;
    data['product_id'] = productId;
    data['slug'] = slug;
    data['image'] = image;
    data['status'] = status;
    data['seller_id'] = sellerId;
    data['delivery_man_id'] = deliveryManId;
    data['name'] = name;
    return data;
  }


}
