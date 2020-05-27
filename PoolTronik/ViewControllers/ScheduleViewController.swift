//
//  ScheduleViewController.swift
//  PoolTronik
//
//  Created by Alexey Kozlov on 08/04/2020.
//  Copyright © 2020 Alexey Kozlov. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var relaySwitch: UISwitch!
    
    
    var relay: Relay?
    var weekDays = DateFormatter().shortStandaloneWeekdaySymbols
    var selectedWeekDays : [String] = []
    var pTScheduleDate : PTScheduleDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let relayArray = LocalDataBase.shared.getRelayArray()
        let index = relayArray.index(where: { $0.onId == self.relay?.onId })
        self.pTScheduleDate = PTScheduleDate(id: 0, relay: index!, status: 0, startDate: "", nextDates: [], duration: 0, iteration: 0, repeatList: [])
        self.setDateLabel(date: self.datePicker.date)
        self.datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        self.datePicker.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        self.nameLabel.text = relay?.name
        
        let firstWeekday = 2 // -> Monday
        self.weekDays = Array((self.weekDays?[firstWeekday-1..<self.weekDays!.count])!) + (self.weekDays?[0..<firstWeekday-1])!
    }
    
    @objc func dateChanged(){
        
        self.setDateLabel(date: self.datePicker.date)
    }
    
    private func setDateLabel(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        
        let dateString = dateFormatter.string(from: self.datePicker.date)
        let daysString = self.selectedWeekDays.joined(separator:", ")
        self.dateLabel.text = dateString + " " + daysString
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        self.pTScheduleDate?.startDate = formatter.string(from: date)
    }
    
    private func disableButtons() {
        self.saveButton.isEnabled = false
        self.cancelButton.isEnabled = false
    }
    
    private func enableButtons() {
        self.saveButton.isEnabled = true
        self.cancelButton.isEnabled = true
    }
    
    private func setNextDates(startDate: Date) {
        var nextDates : [String] = []
        let startDay = self.weekDays?.index(of: startDate.dayOfWeek()!)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
    
        for weekday in self.selectedWeekDays {
            let day = self.weekDays?.index(of: weekday)
            if startDay! > day! {
                let step = (7 - startDay!) + day!
                let nextDate = Calendar.current.date(byAdding: .day, value: step, to: startDate)
                nextDates.append(formatter.string(from: nextDate!))
            }
            else if startDay! < day! {
                let step = day! - startDay!
                let nextDate = Calendar.current.date(byAdding: .day, value: step, to: startDate)
                nextDates.append(formatter.string(from: nextDate!))
            }
            else {
                let nextDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)
                nextDates.append(formatter.string(from: nextDate!))
            }
        }
        self.pTScheduleDate?.nextDates = nextDates
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if let pTScheduleDate = self.pTScheduleDate {
            self.disableButtons()
            NetworkManager.shared.schedule(pTScheduleDate: pTScheduleDate) { [weak self] (succsess) in
                if succsess {
                    DispatchQueue.main.async {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    let alert = UIAlertController(title: "Failed to set", message: "", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    DispatchQueue.main.async {
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
                self?.enableButtons()
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func switchPressed(_ sender: Any) {
        self.pTScheduleDate?.status = self.relaySwitch.isOn ? 0 : 1
    }
}

extension ScheduleViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.weekDays?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCollectionViewCell", for: indexPath as IndexPath) as? DayCollectionViewCell
        cell?.dayLabel.text = self.weekDays?[indexPath.item]

        return cell!
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let weekday = (self.weekDays?[indexPath.row])!
        if self.selectedWeekDays.contains(weekday) {
            self.selectedWeekDays.remove(at: self.selectedWeekDays.index(of: weekday)!)
            let cell = self.collectionView.cellForItem(at: indexPath) as? DayCollectionViewCell
                   cell?.dayLabel.layer.borderColor = UIColor.clear.cgColor
        }
        else {
            self.selectedWeekDays.append(weekday)
            let cell = self.collectionView.cellForItem(at: indexPath) as? DayCollectionViewCell
            cell?.dayLabel.layer.cornerRadius = 5.0
            cell?.dayLabel.layer.borderColor = UIColor.green.cgColor
            cell?.dayLabel.layer.borderWidth = 1.0
        }
        self.setDateLabel(date: self.datePicker.date)
        self.setNextDates(startDate: self.datePicker.date)
    }
}

extension ScheduleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((self.view.frame.size.width - 80)/7.0), height: 30)
    }
    
    
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}
