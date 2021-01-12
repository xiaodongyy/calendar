/*
 * SPDX-FileCopyrightText: 2021 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "attendeesmodel.h"
#include "localcalendar.h"
#include <KLocalizedString>
#include <KPeople/PersonData>

AttendeesModel::AttendeesModel(QObject *parent) : QAbstractListModel {parent}, m_attendees {KCalendarCore::Attendee::List {}}
{
    connect(this, &AttendeesModel::uidChanged, this, &AttendeesModel::loadPersistentData);
    connect(this, &AttendeesModel::calendarChanged, this, &AttendeesModel::loadPersistentData);
}

QHash<int, QByteArray> AttendeesModel::roleNames() const
{
    return {
        {Email, "email"},
        {FullName, "fullName"},
        {Name, "name"},
        {ParticipationStatus, "status"},
        {AttendeeRole, "attendeeRole"}
    };
}

QString AttendeesModel::uid() const
{
    return m_uid;
}

void AttendeesModel::setUid(const QString &uid)
{
    if (m_uid != uid) {
        m_uid = uid;

        Q_EMIT uidChanged();
    }
}

LocalCalendar *AttendeesModel::calendar() const
{
    return m_calendar;
}

void AttendeesModel::setCalendar(LocalCalendar *calendarPtr)
{
    if (m_calendar != calendarPtr) {
        m_calendar = calendarPtr;

        Q_EMIT calendarChanged();
    }
}

QVariant AttendeesModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant {};
    }

    auto row = index.row();

    switch (role) {
    case Email:
        return m_attendees.at(row).email();
    case FullName:
        return m_attendees.at(row).fullName();
    case Name:
        return m_attendees.at(row).name();
    case ParticipationStatus:
        return m_attendees.at(row).status();
    case AttendeeRole:
        return m_attendees.at(row).role();
    default:
        return QVariant {};
    }
}

int AttendeesModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_attendees.count();
}

void AttendeesModel::loadPersistentData()
{
    beginResetModel();

    Incidence::Ptr incidence;
    Calendar::Ptr calendar;

    m_attendees.clear();
    if (m_calendar != nullptr && !m_uid.isEmpty()) {
        incidence = m_calendar->calendar()->incidence(m_uid);
        if (incidence != nullptr) {
            m_attendees = incidence->attendees();
        }
    }

    endResetModel();
}

void AttendeesModel::removeItem(const int row)
{
    beginRemoveRows(QModelIndex(), row, row);

    m_attendees.removeAt(row);

    endRemoveRows();
}

void AttendeesModel::addPersons(const QStringList uris)
{
    if (uris.isEmpty()) {
        return;
    }

    beginResetModel();

    for (const auto &uri : qAsConst(uris)) {
        KPeople::PersonData person {uri, this};
        m_attendees.append({person.name(), person.email(), true});
    }

    endResetModel();
}

QStringList AttendeesModel::emails() const
{
    QStringList emails {};

    for (const auto &a : qAsConst(m_attendees)) {
        emails.append(a.email());
    }

    return emails;
}

QVariantList AttendeesModel::attendees() const
{
    QVariantList l {};
    for (const auto &a : m_attendees) {
        l.append(QVariant::fromValue(a));
    }

    return l;
}
