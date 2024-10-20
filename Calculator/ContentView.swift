import SwiftUI

struct ContentView: View {
    @State private var value1: String = ""
    @State private var value2: String = ""
    @State private var result: String = ""
    @State private var errorMessage: String = ""
    @State private var isInfoVisible: Bool = false
    @State private var infoMessage: String = ""
    
    init() {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        let groupingSeparator = formatter.groupingSeparator ?? ","
        
        if groupingSeparator == "\u{00A0}" {
            _infoMessage = State(initialValue: "You can use basic space!")
        }
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
                NumberTextField(number: $value1, placeholder: "Number 1", placeholderColor: .gray)
                NumberTextField(number: $value2, placeholder: "Number 2", placeholderColor: .gray)
            }

            HStack {
                Spacer()
                
                Button(action: calculateSum) {
                    Text("+")
                        .padding()
                        .foregroundColor(Color.primary)
                        .cornerRadius(8)
                }
                
                Spacer(minLength: 5)
                
                Button(action: calculateDifference) {
                    Text("-")
                        .padding()
                        .foregroundColor(Color.primary)
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Text("Result: \(result)")
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
            let groupingSeparatorText = (groupingSeparator == " " || groupingSeparator == "\u{00A0}")  ? "\t[space]" : ""
            
            let decimalCode = decimalSeparator.unicodeScalars.first?.value ?? 0
            let groupingCode = groupingSeparator.unicodeScalars.first?.value ?? 0
        
            return VStack(alignment: .leading, spacing: 5) {
                Text("Current locale:\t\(Locale.current.identifier)")
                Text("Decimal separator:\t\"\(decimalSeparator)\" \t(U+\(String(format: "%04X", decimalCode)))")
                Text("Digit groups separator:\t\t\"\(groupingSeparator)\" \(groupingSeparatorText) \t(U+\(String(format: "%04X", groupingCode)))")
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
        
        let groupingSeparator = formatter.groupingSeparator ?? ","
        
        if !isValidInput(value1, formatter: formatter) || !isValidInput(value2, formatter: formatter) {
            result = ""
            errorMessage = "Invalid input format!"
            return
        }
        
        guard let num1 = formatter.number(from: value1)?.decimalValue,
              let num2 = formatter.number(from: value2)?.decimalValue else {
            result = ""
            errorMessage = "Invalid input!"
            return
        }
        
        if abs(num1) > 1_000_000_000_000.000000 || abs(num2) > 1_000_000_000_000.000000 {
            result = ""
            errorMessage = "Input value overflow!"
            return
        }
        
        let resultValue = operation(num1, num2)
        
        if abs(resultValue) > 1_000_000_000_000.000000 {
            result = ""
            errorMessage = "Result value overflow!"
        } else {
            result = formatter.string(from: NSDecimalNumber(decimal: resultValue)) ?? "\(resultValue)"
        }
        
        if groupingSeparator == "\u{00A0}" {
            infoMessage = "You can use basic space!"
        }
    }
    
    private func isValidInput(_ input: String, formatter: NumberFormatter) -> Bool {
        let normalizedInput = input.replacingOccurrences(of: "\u{00A0}", with: " ")

        let decimalSeparator = formatter.decimalSeparator ?? "."
        let groupingSeparator = formatter.groupingSeparator ?? ","

        let regexPattern: String
        if groupingSeparator == "\u{00A0}" {
            regexPattern = "^[0-9\(groupingSeparator) ]*(\(decimalSeparator)[0-9]+)?$"
        } else {
            regexPattern = "^[0-9\(groupingSeparator)]*(\(decimalSeparator)[0-9]+)?$"
        }

        let regex = try? NSRegularExpression(pattern: regexPattern)
        let range = NSRange(location: 0, length: normalizedInput.utf16.count)
        return regex?.firstMatch(in: normalizedInput, options: [], range: range) != nil
    }
    
    private func copyResult() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(result, forType: .string)
    }
}

struct NumberTextField: View {
    @Binding var number: String
    var placeholder: String
    var placeholderColor: Color = .gray
    
    var body: some View {
        TextField(placeholder, text: $number)
            .padding(10)
            .textFieldStyle(.roundedBorder)
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.clear, lineWidth: 0))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 12)
    }
}

