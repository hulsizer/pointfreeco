import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Optics
import Styleguide
import Prelude

let minimalNavView = View<(NavStyle.MinimalStyle, Database.User?, Stripe.Subscription.Status?, Route?)> { style, currentUser, currentSubscriptionStatus, currentRoute in
  gridRow([`class`([newNavBarClass(for: style)])], [
    gridColumn(sizes: [:], [
      div([`class`([Class.hide(.desktop)])], [
        a([href(path(to: .secretHome))], [
          img(
            base64: pointFreeDiamondLogoSvgBase64(fill: fillColor(for: style)),
            mediaType: .image(.svg),
            alt: "",
            [`class`([Class.hide(.desktop)])]
          )
          ])
        ])
      ]),

    gridColumn(sizes: [:], [
      div([`class`([Class.grid.center(.mobile)])], [
        div([`class`([Class.hide(.mobile)])], [
          a([href(path(to: .secretHome))], [
            img(
              base64: pointFreeTextLogoSvgBase64(color: fillColor(for: style)),
              mediaType: .image(.svg),
              alt: "",
              [`class`([Class.hide(.mobile)])]
            )
            ])
          ])
        ])
      ]),

    gridColumn(
      sizes: [:],
      currentUser.map { loggedInNavItemsView.view((style, $0, currentSubscriptionStatus)) }
        ?? loggedOutNavItemsView.view((style, currentRoute))
    ),
    ])
}

private let loggedInNavItemsView = View<(NavStyle.MinimalStyle, Database.User, Stripe.Subscription.Status?)> { style, currentUser, currentSubscriptionStatus in
  navItems(
    [
      aboutLinkView,
      currentSubscriptionStatus == .some(.active) ? nil : subscribeLinkView,
      accountLinkView
      ]
      .flatMap(id)
    )
    .view(style)
}

private let loggedOutNavItemsView = navItems([
  aboutLinkView.contramap(first),
  subscribeLinkView.contramap(first),
  logInLinkView
  ])

private func navItems<A>(_ views: [View<A>]) -> View<A> {
  return View { a in
    ul([`class`([navListClass])],
       views
        .map { (curry(li)([`class`([navListItemClass])]) >>> pure) <¢> $0 }
        .concat()
        .view(a)
    )
  }
}

private let aboutLinkView = View<NavStyle.MinimalStyle> { style in
  a([href(path(to: .about)), `class`([navLinkClass(for: style)])], ["About"])
}

private let subscribeLinkView = View<NavStyle.MinimalStyle> { style in
  a([href(path(to: .pricing(nil, nil))), `class`([navLinkClass(for: style)])], ["Subscribe"])
}

private let accountLinkView = View<NavStyle.MinimalStyle> { style in
  a([href(path(to: .account(.index))), `class`([navLinkClass(for: style)])], ["Account"])
}

private let logInLinkView = View<(NavStyle.MinimalStyle, Route?)> { style, currentRoute in
  gitHubLink(text: "Log in", type: gitHubLinkType(for: style), redirectRoute: currentRoute)
}

private func gitHubLinkType(for style: NavStyle.MinimalStyle) -> GitHubLinkType {
  switch style {
  case .dark:
    return .white
  case .light:
    return .black
  }
}

private func navLinkClass(for style: NavStyle.MinimalStyle) -> CssSelector {
  switch style {
  case .dark:
    return Class.pf.colors.link.green
  case .light:
    return Class.pf.colors.link.black
  }
}

private let navListItemClass =
  Class.padding([.mobile: [.left: 3]])
    | Class.display.inline

private let navListClass =
  Class.type.list.reset
    | Class.grid.end(.mobile)

private func newNavBarClass(for style: NavStyle.MinimalStyle) -> CssSelector {
  let colorClass: CssSelector
  switch style {
  case .dark:
    colorClass = Class.pf.colors.bg.purple150
  case .light:
    colorClass = Class.pf.colors.bg.blue900
  }

  return colorClass
    | Class.padding([.mobile: [.leftRight: 2, .topBottom: 2], .desktop: [.topBottom: 4]])
    | Class.grid.middle(.mobile)
    | Class.grid.between(.mobile)
}

private func fillColor(for minimalStyle: NavStyle.MinimalStyle) -> String {
  switch minimalStyle {
  case .dark:
    return "#ffffff"
  case .light:
    return "#121212"
  }
}
