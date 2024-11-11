import SwiftUI

struct ContentView: View {
    @State private var value1: String = ""
    @State private var value2: String = ""
    @State private var result: Decimal = 0
    @State private var errorMessage: String = ""
    @State private var isInfoVisible: Bool = false
    @State private var infoMessage: String = ""
    
    init() {
        _infoMessage = State(initialValue: "You can use basic space as a grouping separator!")
    }
    
    var resultOrEmpty: String {
        errorMessage.isEmpty ? formattedResult(result) : ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                
                Button(action: {
                    isInfoVisible.toggle()
                }) {
                    Text(isInfoVisible ? "Hide info" : "Show info")
                        .padding()
                        .foregroundColor(Color.primary)
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            
            if isInfoVisible {
                VStack(spacing: 10) {
                    HStack {
                        Spacer()
                        Text("Довгий Александр Сергеевич").bold()
                        Spacer()
                    }
                    
                    Divider()
                    
                    HStack {
                        Spacer()
                        Text("Курс: 3")
                        Spacer()
                    }
                    
                    Divider()
                    
                    HStack {
                        Spacer()
                        Text("Группа: 11")
                        Spacer()
                    }
                    
                    Divider()
                    
                    HStack {
                        Spacer()
                        Text("Год: 2024")
                        Spacer()
                    }
                }
                .padding(.top, 10)
            }
            
            HStack {
                NumberTextField(number: $value1, placeholder: "Number 1")
                NumberTextField(number: $value2, placeholder: "Number 2")
            }

            HStack {
                Spacer()
                
                Button(action: calculateSum) {
                    Text("+")
                        .padding()
                        .foregroundColor(Color.primary)
                        .cornerRadius(8)
                        .bold()
                        .font(.title2)
                }
                
                Spacer(minLength: 5)
                
                Button(action: calculateDifference) {
                    Text("-")
                        .padding()
                        .foregroundColor(Color.primary)
                        .cornerRadius(8)
                        .bold()
                        .font(.title2)
                }
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Text("Result: \(resultOrEmpty)")
                    .bold()
                    .contextMenu {
                        Button(action: copyResult) {
                            Text("Copy")
                            Image(systemName: "doc.on.doc")
                        }
                    }
                Text(errorMessage).foregroundColor(.red)
                
                Spacer()
            }
            .padding(.top)
            
            Divider()
            
            localeInfoView()
                .font(.footnote)
                .padding(.top, 20)
            
            if !infoMessage.isEmpty {
                Text(infoMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 10)
            }
        }
        .padding()
        .background(Color(nsColor: .windowBackgroundColor))
        .foregroundColor(Color.primary)
        .frame(width: 600, height: 600)
        .frame(maxWidth: 600)
        .border(Color.gray, width: 1)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains(.command) && event.characters == "c" {
                    copyResult()
                }
                return event
            }
        }
    }
    
    private func localeInfoView() -> some View {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        let decimalSeparator = formatter.decimalSeparator ?? "."
        let groupingSeparator = formatter.groupingSeparator ?? ","
        let groupingSeparatorText = (groupingSeparator == " " || groupingSeparator == "\u{00A0}") ? "[space]" : ""
        
        let decimalCode = decimalSeparator.unicodeScalars.first?.value ?? 0
        let groupingCode = groupingSeparator.unicodeScalars.first?.value ?? 0
        
        return VStack(alignment: .leading, spacing: 5) {
            Text("Current locale:\t\(Locale.current.identifier)")
            Text("Decimal separator:\t\"\(decimalSeparator)\" \t(U+\(String(format: "%04X", decimalCode)))")
            Text("Digit groups separator:\t\t\"\(groupingSeparator)\"\t \(groupingSeparatorText) \t(U+\(String(format: "%04X", groupingCode)))")
        }
    }
    
    private func calculateSum() {
        performCalculation(operation: +)
    }
    
    private func calculateDifference() {
        performCalculation(operation: -)
    }
    
    private func performCalculation(operation: (Decimal, Decimal) -> Decimal) {
        errorMessage = ""

        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 20
        
        let groupingSeparator = formatter.groupingSeparator ?? ","
        let decimalSeparator = formatter.decimalSeparator ?? "."

        guard isValidFormat(value1, groupingSeparator: groupingSeparator, decimalSeparator: decimalSeparator),
              isValidFormat(value2, groupingSeparator: groupingSeparator, decimalSeparator: decimalSeparator) else {
            result = 0
            errorMessage = "Invalid input format!"
            return
        }

        guard let num1 = normalizedDecimal(from: value1, formatter: formatter),
              let num2 = normalizedDecimal(from: value2, formatter: formatter) else {
            result = 0
            errorMessage = "Error occured!"
            return
        }
        
        if abs(num1) > 1_000_000_000_000.000000 || abs(num2) > 1_000_000_000_000.000000 {
            result = 0
            errorMessage = "Input value overflow!"
            return
        }
        
        // print("num1: \(num1), num2: \(num2)") // Debug print
        
        let resultValue = operation(num1, num2)
        
        if abs(resultValue) > 1_000_000_000_000.000000 {
            result = 0
            errorMessage = "Result value overflow!"
        } else {
            result = resultValue
        }
        
        // print("Result: \(result)") // Debug print
    }
    
    private func normalizedDecimal(from input: String, formatter: NumberFormatter) -> Decimal? {
        let groupingSeparator = formatter.groupingSeparator ?? ","
        let decimalSeparator = formatter.decimalSeparator ?? "."
        
        let normalizedInput = input
            .replacingOccurrences(of: groupingSeparator, with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: decimalSeparator, with: ".")

        return Decimal(string: normalizedInput)
    }

    private func isValidFormat(_ input: String, groupingSeparator: String, decimalSeparator: String) -> Bool {
        let regexPattern = "^[0-9]{1,3}([ \(groupingSeparator)]?[0-9]{3})*(\(decimalSeparator)[0-9]+)?$"
        let regex = try? NSRegularExpression(pattern: regexPattern)

        let range = NSRange(location: 0, length: input.utf16.count)
        if let match = regex?.firstMatch(in: input, options: [], range: range) {
            return match.range == range
        }
        
        return false
    }
    
    private func copyResult() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(formattedResult(result), forType: .string)
    }

    private func formattedResult(_ number: Decimal) -> String {
        let nsDecimalNumber = NSDecimalNumber(decimal: number)
        let numberString = nsDecimalNumber.stringValue
        
        let formatter = NumberFormatter()
        let groupingSeparator = formatter.groupingSeparator ?? ","
        let decimalSeparator = formatter.decimalSeparator ?? "."

        let components = numberString.split(separator: ".", omittingEmptySubsequences: false)
        guard let integerPart = components.first else { return numberString }
        let fractionalPart = components.count > 1 ? String(components[1]) : ""

        let integerPartWithGrouping = addGroupingSeparators(to: String(integerPart), groupingSeparator: groupingSeparator)
        
        return fractionalPart.isEmpty ? integerPartWithGrouping : "\(integerPartWithGrouping)\(decimalSeparator)\(fractionalPart)"
    }
    
    private func addGroupingSeparators(to integerPart: String, groupingSeparator: String) -> String {
        var result = ""
        var counter = 0

        for char in integerPart.reversed() {
            if counter > 0 && counter % 3 == 0 {
                result.append(groupingSeparator)
            }
            result.append(char)
            counter += 1
        }

        return String(result.reversed())
    }
}

struct NumberTextField: View {
    @Binding var number: String
    var placeholder: String
    var placeholderColor: Color = .gray
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TextField(placeholder, text: $number)
            .padding(10)
            .textFieldStyle(.roundedBorder)
            .background(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white)
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.clear, lineWidth: 0))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 12)
    }
}
