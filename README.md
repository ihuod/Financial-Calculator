# Financial-Calculator

**Overview**

The Financial Calculator is a simple yet powerful SwiftUI application designed for performing basic arithmetic operations on large decimal numbers. It supports addition and subtraction with high precision, up to 20 decimal places, and adapts to the user’s locale, ensuring the correct use of decimal and grouping separators.

**Features**

- Localized Number Formatting: Automatically adapts to the user’s locale, supporting different decimal and grouping separators (e.g., commas or periods for decimals).
- High Precision: Supports calculations with up to 20 decimal places for precise financial computations.
- Overflow Handling: Prevents input or result overflow by limiting the values to a safe range for stable performance.
- Simple and Intuitive Interface: Clean design with two input fields and buttons for easy number entry and operations.
- Contextual Copy Feature: Allows users to copy the result directly to the clipboard using the context menu or by pressing Cmd+C.
- Toggleable Info Section: Displays additional information (e.g., student name, course details) when the “Show info” button is clicked.

**Requirements**

- macOS: Requires the latest version of macOS (macOS 14 Sonoma or later).
- Xcode: Ensure you have the latest version of Xcode installed for building and running the app.

**Installation**

Clone the repository:

```git clone https://github.com/ihuod/financial-calculator.git```

**Run** <br>

Run calculator.app file from the latest release.

**Usage**

	1.	Enter the first number in the “Number 1” field.
	2.	Enter the second number in the “Number 2” field.
	3.	Click the + button to calculate the sum, or the - button to calculate the difference.
	4.	The result will be displayed below the buttons.
	5.	Copy the result:
	6.	Right-click on the result and choose “Copy” from the context menu.
	7.	Alternatively, press Cmd+C to copy the result to the clipboard.

**Localized Number Input**

-	The application automatically handles the decimal and grouping separators based on the user’s locale. For example:
    - US locale: Decimal separator is a period (.), and grouping separator is a comma (,).
    - European locales: Decimal separator is a comma (,), and grouping separator might be a space or period.

**Error Handling**

-	Invalid Input: If you enter an invalid number (e.g., characters that don’t match the number format), the app will display an error message.
-	Overflow: If the input or result exceeds the allowed range (over 1 trillion), an overflow message will be shown.
