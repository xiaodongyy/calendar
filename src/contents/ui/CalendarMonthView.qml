/*
 *   Copyright 2019-2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.0 as Kirigami
import org.kde.phone.calindori 0.1

/**
 * Calendar component that displays:
 *  - a header with currrent day's information
 *  - a table (grid) with the days of the current month
 *  - a set of actions to navigate between months
 * It offers vertical swiping
 */
Controls2.SwipeView {
    id: root

    property alias selectedDate: monthView.selectedDate
    property alias displayedMonthName: monthView.displayedMonthName
    property alias displayedYear: monthView.displayedYear
    property alias showHeader: monthView.showHeader
    property alias showMonthName: monthView.showMonthName
    property alias showYear: monthView.showYear
    property int previousIndex
    property var cal
    /**
     * @brief When set, we take over the handling of the container items indexes programmatically
     *
     */
    property bool manualIndexing: false

    signal nextMonth
    signal previousMonth
    signal goToday
    /**
     * @brief It should be emitted when the SwipeView currentIndex is set to the first or the last one
     *
     * @param lastDate p_lastDate:...
     */
    signal viewEnd(var lastDate)

    onNextMonth: {
        mm.goNextMonth();
        root.selectedDate = new Date(mm.year, mm.month-1, 1, root.selectedDate.getHours(), root.selectedDate.getMinutes());
    }

    onPreviousMonth: {
        mm.goPreviousMonth();
        root.selectedDate = new Date(mm.year, mm.month-1, 1, root.selectedDate.getHours(), root.selectedDate.getMinutes());
    }

    onGoToday: {
        mm.goCurrentMonth();
        root.selectedDate = new Date();
    }

    onCurrentItemChanged: manageIndex()

    function manageIndex ()
    {
        if(!manualIndexing)
        {
            return;
        }

        (currentIndex < previousIndex) ? previousMonth() : nextMonth();
        previousIndex = currentIndex;

        if(currentIndex != 1)
        {
            viewEnd(root.selectedDate) //Inform parents about the date to set as selected when re-pushing this page
        }
    }

    Connections {
        target: cal

        onTodosChanged: monthView.reloadSelectedDate()
        onEventsChanged: monthView.reloadSelectedDate()
    }

    Component.onCompleted: {
        currentIndex = 1;
        previousIndex = currentIndex;
        manualIndexing = true;
        orientation = Qt.Vertical //Change orientation after the object has been instantiated. Otherwise, we get a non-intuitive animation when swiping upwards
    }

    orientation: Qt.Horizontal

    DaysOfMonthIncidenceModel {
        id: mm

        year: monthView.selectedDate.getFullYear()
        month: monthView.selectedDate.getMonth() + 1
        calendar: cal
    }

    Item {}

    Item {
        MonthView {
            id: monthView

            anchors.centerIn: parent
            displayedYear: mm.year
            displayedMonthName: Qt.locale().standaloneMonthName(mm.month-1)
            selectedDayTodosCount: cal.todosCount(selectedDate)
            selectedDayEventsCount: cal.eventsCount(selectedDate)
            daysModel: mm

            reloadSelectedDate: function() {
                selectedDayTodosCount = cal.todosCount(root.selectedDate)
                selectedDayEventsCount = cal.eventsCount(root.selectedDate)
            }
        }
    }

    Item {}
}
