//
//  TagPicker.swift
//  JPouch
//
//  Created by Riley Goldman on 4/29/24.
//

import SwiftUI

struct TagPicker: View {
    @State var values: Set<String>
    @Binding var selection: Set<String>
    @Binding var height: CGFloat
    @State private var customTag: String = ""

    var body: some View {
        GeometryReader { geometry in
            LazyVStack(alignment: .leading) {
                self.generateContent(in: geometry)
                TextField("Enter a custom tag...", text: $customTag)
                    .padding()
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        selection.insert(customTag)
                        values.insert(customTag)
                        customTag = ""
                    }
            }
        }
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        let tagList = self.values.union(self.selection).sorted(by: <)
        
        return ZStack(alignment: .topLeading) {
            ForEach(tagList, id: \.self) { tagName in
                self.makeTag(tagName)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tagName == tagList.last {
                            width = 0 /// last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if tagName == tagList.last {
                            self.height = abs(height) + 90
                            height = 0 /// last item
                        }
                        return result
                    })
            }
        }
    }
    
    private func toggleSelection(_ value: String) {
        if (selection.contains(value)) {
            selection.remove(value)
        }
        else {
            selection.insert(value)
        }
    }
    
    private func makeTag(_ tagValue: String) -> some View {
        let isSelected = selection.contains(tagValue)
        let systemImage: String = isSelected ? "checkmark.circle" : "minus.circle"
        let bgColor = isSelected ? Color.blue : Color.clear
        let textColor = isSelected ? Color.white : Color.gray
        
        let tag = Button(
            action: {
                toggleSelection(tagValue)
            },
            label: {
                Label(tagValue + "  ", systemImage: systemImage)
                    .font(.caption)
                    .cornerRadius(100)
                    .padding(5)
                    .lineLimit(1)
            }
        )
        .buttonStyle(BorderlessButtonStyle())
        .background(bgColor)
        .foregroundColor(textColor)
        .cornerRadius(100)
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: 20)
                .stroke(textColor, lineWidth: 1)
        )
        .padding(5)
        
        return AnyView(tag)
    }
}


#Preview {
    TagPicker(
        values: ["sample", "really cool but also really long", "something else", "another"],
        selection: .constant(["sample", "dynamic"]),
        height: .constant(150)
    )
}
