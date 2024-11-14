#if os(macOS)
import SwiftUI

extension KeyboardShortcuts {
	private struct _Recorder: NSViewRepresentable { // swiftlint:disable:this type_name
		typealias NSViewType = RecorderCocoa

		let name: Name
		let onChange: ((_ shortcut: Shortcut?) -> Void)?
		let isLocal: Bool

		func makeNSView(context: Context) -> NSViewType {
			.init(for: name, onChange: onChange, isLocal: isLocal)
		}

		func updateNSView(_ nsView: NSViewType, context: Context) {
			nsView.shortcutName = name
			nsView.isLocal = isLocal
		}
	}

	/**
	A SwiftUI `View` that lets the user record a keyboard shortcut.

	You would usually put this in your settings window.

	It automatically prevents choosing a keyboard shortcut that is already taken by the system or by the app's main menu by showing a user-friendly alert to the user.

	It takes care of storing the keyboard shortcut in `UserDefaults` for you.

	```swift
	import SwiftUI
	import KeyboardShortcuts

	struct SettingsScreen: View {
		var body: some View {
			Form {
				KeyboardShortcuts.Recorder("Toggle Unicorn Mode:", name: .toggleUnicornMode)
			}
		}
	}
	```

	- Note: Since macOS 15, for sandboxed apps, it's [no longer possible](https://developer.apple.com/forums/thread/763878?answerId=804374022#804374022) to specify the `Option` key without also using `Command` or `Control`.
	*/
	public struct Recorder<Label: View>: View { // swiftlint:disable:this type_name
		private let name: Name
		private let onChange: ((Shortcut?) -> Void)?
		private let hasLabel: Bool
		private let label: Label
		private let isLocal: Bool

		init(
			for name: Name,
			onChange: ((Shortcut?) -> Void)? = nil,
			hasLabel: Bool,
			@ViewBuilder label: () -> Label,
			isLocal: Bool = false
		) {
			self.name = name
			self.onChange = onChange
			self.hasLabel = hasLabel
			self.label = label()
			self.isLocal = isLocal
		}

		public var body: some View {
			if hasLabel {
				if #available(macOS 13, *) {
					LabeledContent {
						_Recorder(
							name: name,
							onChange: onChange,
							isLocal: isLocal
						)
					} label: {
						label
					}
				} else {
					_Recorder(
						name: name,
						onChange: onChange,
						isLocal: isLocal
					)
						.formLabel {
							label
						}
				}
			} else {
				_Recorder(
					name: name,
					onChange: onChange,
					isLocal: isLocal
				)
			}
		}
	}
}

extension KeyboardShortcuts.Recorder<EmptyView> {
	/**
	- Parameter name: Strongly-typed keyboard shortcut name.
	- Parameter onChange: Callback which will be called when the keyboard shortcut is changed/removed by the user. This can be useful when you need more control. For example, when migrating from a different keyboard shortcut solution and you need to store the keyboard shortcut somewhere yourself instead of relying on the built-in storage. However, it's strongly recommended to just rely on the built-in storage when possible.
	*/
	public init(
		for name: KeyboardShortcuts.Name,
		onChange: ((KeyboardShortcuts.Shortcut?) -> Void)? = nil,
		isLocal: Bool = false
	) {
		self.init(
			for: name,
			onChange: onChange,
			hasLabel: false,
			isLocal: isLocal
		) {}
	}
}

extension KeyboardShortcuts.Recorder<Text> {
	/**
	- Parameter title: The title of the keyboard shortcut recorder, describing its purpose.
	- Parameter name: Strongly-typed keyboard shortcut name.
	- Parameter onChange: Callback which will be called when the keyboard shortcut is changed/removed by the user. This can be useful when you need more control. For example, when migrating from a different keyboard shortcut solution and you need to store the keyboard shortcut somewhere yourself instead of relying on the built-in storage. However, it's strongly recommended to just rely on the built-in storage when possible.
	*/
	public init(
		_ title: LocalizedStringKey,
		name: KeyboardShortcuts.Name,
		onChange: ((KeyboardShortcuts.Shortcut?) -> Void)? = nil
	) {
		self.init(
			for: name,
			onChange: onChange,
			hasLabel: true
		) {
			Text(title)
		}
	}
}

extension KeyboardShortcuts.Recorder<Text> {
	/**
	- Parameter title: The title of the keyboard shortcut recorder, describing its purpose.
	- Parameter name: Strongly-typed keyboard shortcut name.
	- Parameter onChange: Callback which will be called when the keyboard shortcut is changed/removed by the user. This can be useful when you need more control. For example, when migrating from a different keyboard shortcut solution and you need to store the keyboard shortcut somewhere yourself instead of relying on the built-in storage. However, it's strongly recommended to just rely on the built-in storage when possible.
	*/
	@_disfavoredOverload
	public init(
		_ title: String,
		name: KeyboardShortcuts.Name,
		onChange: ((KeyboardShortcuts.Shortcut?) -> Void)? = nil
	) {
		self.init(
			for: name,
			onChange: onChange,
			hasLabel: true
		) {
			Text(title)
		}
	}
}

extension KeyboardShortcuts.Recorder {
	/**
	- Parameter name: Strongly-typed keyboard shortcut name.
	- Parameter onChange: Callback which will be called when the keyboard shortcut is changed/removed by the user. This can be useful when you need more control. For example, when migrating from a different keyboard shortcut solution and you need to store the keyboard shortcut somewhere yourself instead of relying on the built-in storage. However, it's strongly recommended to just rely on the built-in storage when possible.
	- Parameter label: A view that describes the purpose of the keyboard shortcut recorder.
	*/
	public init(
		for name: KeyboardShortcuts.Name,
		onChange: ((KeyboardShortcuts.Shortcut?) -> Void)? = nil,
		@ViewBuilder label: () -> Label
	) {
		self.init(
			for: name,
			onChange: onChange,
			hasLabel: true,
			label: label
		)
	}
}

#Preview {
	KeyboardShortcuts.Recorder("record_shortcut", name: .init("xcodePreview"))
		.environment(\.locale, .init(identifier: "en"))
}

#Preview {
	KeyboardShortcuts.Recorder("record_shortcut", name: .init("xcodePreview"))
		.environment(\.locale, .init(identifier: "zh-Hans"))
}

#Preview {
	KeyboardShortcuts.Recorder("record_shortcut", name: .init("xcodePreview"))
		.environment(\.locale, .init(identifier: "ru"))
}
#endif
