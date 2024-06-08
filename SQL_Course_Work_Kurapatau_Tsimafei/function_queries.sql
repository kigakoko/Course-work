-- function queries
SELECT add_user('username', 'email@example.com', 'password', 'user');
SELECT add_washing_machine('BrandB', 'ModelY', 350.00, 'A+', 5);
SELECT add_category('Top Load', 'Top load washing machines');

SELECT place_order(
    p_user_id := 1,
    p_total_amount := 500.00,
    p_order_status := 'Processing',
    p_items := '[{"washing_machine_id": 1, "quantity": 2, "unit_price": 250.00}]'::json
);

SELECT update_order_status(1, 'Delivered');