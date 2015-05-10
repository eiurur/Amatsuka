# SCSS

### 明度

    lighten(red, 30%);
    darken(red, 30%);

### 彩度

    saturate(red, 20%);
    desaturate(red, 20%);

### 透明度

    transparentize(red, 0.8);
    rgba(red, 0.2);

# 規約

規約は原則 BEM を使用する

## BEM

親の要素となるような要素をBlockとして命名

    .item
    .item-list
    .form
    .form-search
    .form-search-item

ElementはBlockに内包される部品。Elementが集まったものがBlockになるので、ElementはBlock内部に存在します。

    .item__text
    .item-list__btn
    .form__input
    .form-search__title
    .form-search-item__user

Modifierは状態を表すときに使用されます。

    .item--red
    .item-list__btn--type_success
    .form__input--active
    .form-search__title--hover
    .form-search-result__user--following

### その他

- CSSプロパティはアルファベット順