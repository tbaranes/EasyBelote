// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum Game {
    /// Who's bidding?
    internal static let bidding = L10n.tr("Localizable", "game.bidding")
    internal enum Round {
      /// Contract
      internal static let enterContract = L10n.tr("Localizable", "game.round.enter_contract")
      /// Score
      internal static let enterScore = L10n.tr("Localizable", "game.round.enter_score")
      /// Save
      internal static let save = L10n.tr("Localizable", "game.round.save")
      internal enum Declaration {
        /// Belote & re
        internal static let belote = L10n.tr("Localizable", "game.round.declaration.belote")
        /// Capot
        internal static let capot = L10n.tr("Localizable", "game.round.declaration.capot")
        /// Coinche
        internal static let coinche = L10n.tr("Localizable", "game.round.declaration.coinche")
        /// Quarte
        internal static let quarte = L10n.tr("Localizable", "game.round.declaration.quarte")
        /// Quinte
        internal static let quinte = L10n.tr("Localizable", "game.round.declaration.quinte")
        /// Square
        internal static let square = L10n.tr("Localizable", "game.round.declaration.square")
        /// 4 of jacks
        internal static let squareJacks = L10n.tr("Localizable", "game.round.declaration.squareJacks")
        /// 4 of nines
        internal static let squareNines = L10n.tr("Localizable", "game.round.declaration.squareNines")
        /// Surcoinche
        internal static let surcoinche = L10n.tr("Localizable", "game.round.declaration.surcoinche")
        /// Tierce
        internal static let tierce = L10n.tr("Localizable", "game.round.declaration.tierce")
      }
    }
  }

  internal enum Home {
    /// New game
    internal static let newGame = L10n.tr("Localizable", "home.new_game")
  }

  internal enum NewGame {
    /// Coinche
    internal static let coinche = L10n.tr("Localizable", "new_game.coinche")
    /// Declarations
    internal static let declarations = L10n.tr("Localizable", "new_game.declarations")
    /// Number of points
    internal static let nbPoints = L10n.tr("Localizable", "new_game.nb_points")
    /// 1001
    internal static let nbPointsPlaceholder = L10n.tr("Localizable", "new_game.nb_points_placeholder")
    /// Start game
    internal static let startGame = L10n.tr("Localizable", "new_game.start_game")
    internal enum Players {
      /// To your left
      internal static let onLeft = L10n.tr("Localizable", "new_game.players.on_left")
      /// To your right
      internal static let onRight = L10n.tr("Localizable", "new_game.players.on_right")
      /// Enter a name
      internal static let placeholder = L10n.tr("Localizable", "new_game.players.placeholder")
      /// You
      internal static let you = L10n.tr("Localizable", "new_game.players.you")
      /// Your Partner
      internal static let yourPartner = L10n.tr("Localizable", "new_game.players.your_partner")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
