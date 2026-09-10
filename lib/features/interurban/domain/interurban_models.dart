import 'package:flutter/material.dart';

enum ComfortLevel { standard, vip, vipPlus }

extension ComfortLevelX on ComfortLevel {
  String get label => switch (this) {
        ComfortLevel.standard => 'Standard',
        ComfortLevel.vip => 'VIP',
        ComfortLevel.vipPlus => 'VIP+',
      };
}

class BusCompany {
  const BusCompany({
    required this.id,
    required this.name,
    required this.fullName,
    required this.color,
    required this.rating,
    required this.citiesServed,
  });

  final String id;
  final String name;
  final String fullName;
  final Color color;
  final double rating;
  final List<String> citiesServed;
}

class BusTrip {
  const BusTrip({
    required this.id,
    required this.company,
    required this.originCity,
    required this.destinationCity,
    required this.departure,
    required this.durationMinutes,
    required this.price,
    required this.comfort,
    required this.hasAc,
    required this.totalSeats,
    required this.availableSeats,
  });

  final String id;
  final BusCompany company;
  final String originCity;
  final String destinationCity;
  final DateTime departure;
  final int durationMinutes;
  final double price;
  final ComfortLevel comfort;
  final bool hasAc;
  final int totalSeats;
  final int availableSeats;

  DateTime get arrival => departure.add(Duration(minutes: durationMinutes));
}

class BusSeat {
  const BusSeat({required this.number, required this.taken});

  final int number;
  final bool taken;
}

enum BookingStatus { confirmed, cancelled, completed }

class TripBooking {
  const TripBooking({
    required this.id,
    required this.trip,
    required this.passengerName,
    required this.seatNumbers,
    required this.totalPrice,
    required this.bookedAt,
    this.status = BookingStatus.confirmed,
  });

  final String id;
  final BusTrip trip;
  final String passengerName;
  final List<int> seatNumbers;
  final double totalPrice;
  final DateTime bookedAt;
  final BookingStatus status;

  String get qrPayload =>
      'TRANSITCI|BOOKING:$id|TRIP:${trip.id}|SEATS:${seatNumbers.join(',')}|NAME:$passengerName';
}
